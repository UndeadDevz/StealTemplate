-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- modules
local DAILY_REWARD_CONFIG = require(ReplicatedStorage.Shared.DailyReward.DAILY_REWARD_CONFIG)
local DataManager = require(ServerScriptService.Data.DataManager)
local DailyReward = require(script.Parent.DailyReward)

-- remotes
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local functionsFolder = remotesFolder:WaitForChild("Functions")
local promptDailyRewardFunction = functionsFolder:WaitForChild("PromptDailyReward")

-- values
local AUTOSAVE_DELAY = 60

-- functions
function GetRewardStatus(player, playerRewardData)
	-- Cheat Sheet: (0 = IGNORE, 1 = REDEEM, 2 = RESET)
	if playerRewardData.NextDailyRewardTime == 0 then
		-- player has no data (reset and start them off at day 1)
		print("Daily rewards started for: ", player.Name)
		return 2
	else	
		if os.time() > playerRewardData.NextDailyRewardTime then			
			if playerRewardData.RewardRedeemable and DAILY_REWARD_CONFIG.RESET_STREAK_IF_MISSED then
				-- player is outside the redeem period (reset)
				print("Daily reward redeem period expired: ", player.Name)
				return 2 
			else		
				-- player has redeemed reward already, and cooldown has expired and we increment to the next day		
				if playerRewardData.CurrentDay < DAILY_REWARD_CONFIG.MAX_DAYS then
					DailyReward.AddToPlayerData(player, "CurrentDay", 1)
				else
					DailyReward.SetPlayerData(player, "CurrentDay", 1)
				end
				DailyReward.SetPlayerData(player, "NextDailyRewardTime", os.time()+DAILY_REWARD_CONFIG.COOLDOWN_SECONDS)	
				DailyReward.SetPlayerData(player, "RewardRedeemable", true)
				print("Next day's reward unlocked: ", player.Name)
				return 1
			end
		else	
			if playerRewardData.RewardRedeemable then
				-- player is within redeem period and yet to do so (redeemable)
				print("Reward is still eligible to redeem: ", player.Name)
				return 1
			end
		end	
	end
	
	-- player has no reward to claim yet
	print("Not eligible to claim any rewards yet: ", player.Name)
	return 0 
end

function GivePlayerReward(player, dayID)
	local dayPreset = DAILY_REWARD_CONFIG.DAY_PRESETS["Day " .. dayID]
	if not dayPreset then
		warn("No reward preset found for Day " .. dayID)
		return
	end

	local rewardType = dayPreset.reward_type
	local rewardAmount = dayPreset.reward_amount

	if rewardAmount <= 0 then
		warn("Reward not configured for Day " .. dayID)
		return
	end

	-- Esperar a que el profile del DataManager esté cargado
	local attempts = 0
	while not DataManager.Profiles[player] and attempts < 50 do
		task.wait(0.1)
		attempts += 1
	end

	if not DataManager.Profiles[player] then
		warn("[DailyReward] Profile not loaded for " .. player.Name .. ", reward not given")
		return
	end

	if rewardType == "Wins" then
		DataManager.AddStat(player, "Wins", rewardAmount)
		print("[DailyReward] Gave " .. rewardAmount .. " Wins to " .. player.Name .. " (Day " .. dayID .. ")")
	elseif rewardType == "Speed" then
		-- Dar EXP actual para subir niveles + TotalEXP para el leaderstat
		DataManager.AddStat(player, "EXP", rewardAmount)
		DataManager.AddStat(player, "TotalEXP", rewardAmount)
		DataManager.CheckLevelUp(player)
		print("[DailyReward] Gave " .. rewardAmount .. " Speed/EXP to " .. player.Name .. " (Day " .. dayID .. ")")
	elseif rewardType == "Special" then
		-- TODO: implementar recompensa especial del día 7
		warn("Special reward not implemented yet for Day " .. dayID)
	end
end

-- player data
Players.PlayerAdded:Connect(function(player)
	if not DAILY_REWARD_CONFIG.ENABLED then return end

	local playerRewardData, playerSessionData = DailyReward.AddPlayer(player)
	if playerSessionData.DataStatus == 1 then	
		local rewardStatus = GetRewardStatus(player, playerRewardData)	
		if rewardStatus == 2 then	
			DailyReward.SetPlayerData(player, "CurrentDay", 1)
			DailyReward.SetPlayerData(player, "NextDailyRewardTime", os.time()+DAILY_REWARD_CONFIG.COOLDOWN_SECONDS)	
			DailyReward.AddToPlayerData(player, "CurrentDailyRewardStreak", 0)	
			DailyReward.SetPlayerData(player, "RewardRedeemable", true)	
		end
		
		-- check if player is able to claim a reward
		if rewardStatus >= 1 then	
			task.defer(function()
				local success, err = pcall(function()
					promptDailyRewardFunction:InvokeClient(player, playerRewardData)
				end)		
				if success then
					DailyReward.AddToPlayerData(player, "TotalDailyRewardsClaimed", 1)	
					DailyReward.AddToPlayerData(player, "CurrentDailyRewardStreak", 1)				
					local longestDailyRewardStreak = DailyReward.GetPlayerData(player, "LongestDailyRewardStreak")
					local currentDailyRewardStreak = DailyReward.GetPlayerData(player, "CurrentDailyRewardStreak")
					if currentDailyRewardStreak > longestDailyRewardStreak then
						DailyReward.SetPlayerData(player, "LongestDailyRewardStreak", currentDailyRewardStreak)
					end
					DailyReward.SetPlayerData(player, "RewardRedeemable", false)
					GivePlayerReward(player, playerRewardData.CurrentDay)
				else
					warn(err)
				end
			end)
		end	
	end
end)

Players.PlayerRemoving:Connect(function(player)
	DailyReward.RemovePlayer(player)
end)

-- server close
game:BindToClose(function()
	for _, player in pairs(Players:GetPlayers()) do
		DailyReward.RemovePlayer(player)
	end
end)

--  autosave
task.spawn(function()
	while task.wait(AUTOSAVE_DELAY) do
		local executed, total = 0, 0
		for _, player in pairs(Players:GetPlayers()) do
			local success = DailyReward.SavePlayerData(player)
			total += 1
			if success then
				executed += 1
			end
		end
		print("Players Data Autosaved: ("..tostring(executed).."/"..tostring(total)..")")
	end
end)