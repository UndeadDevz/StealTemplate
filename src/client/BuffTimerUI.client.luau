local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Assume SpeedEffectFrame and WinEffectFrame exist in Buttons ScreenGui with TextLabel Counter
local buttonsGui = playerGui:WaitForChild("Buttons")
local speedEffectFrame = buttonsGui:WaitForChild("SpeedEffectFrame")
local winEffectFrame = buttonsGui:WaitForChild("WinEffectFrame")

-- Hide frames initially
speedEffectFrame.Visible = false
winEffectFrame.Visible = false

local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local getStat = remoteEvents:WaitForChild("GetStat")

local buffActivatedEvent = remoteEvents:WaitForChild("BuffActivated")

local activeBuffs = {}  -- {potionType: endTime}

local function LoadExistingBuffs()
	local now = os.time()
	local speedEndTime = getStat:InvokeServer("SpeedPotionEndTime") or 0
	if speedEndTime > now then
		activeBuffs["SpeedPotion"] = speedEndTime
	end
	local winsEndTime = getStat:InvokeServer("WinsPotionEndTime") or 0
	if winsEndTime > now then
		activeBuffs["WinsPotion"] = winsEndTime
	end
end

local function FormatTime(seconds)
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", mins, secs)
end

local function UpdateTimers()
	while true do
		task.wait(1)
		local now = os.time()
		for potionType, endTime in pairs(activeBuffs) do
			local frame = (potionType == "SpeedPotion") and speedEffectFrame or winEffectFrame
			local counterLabel = frame:FindFirstChild("Counter")
			if counterLabel then
				local remaining = endTime - now
				if remaining > 0 then
					counterLabel.Text = FormatTime(remaining)
					frame.Visible = true
				else
					frame.Visible = false
					activeBuffs[potionType] = nil
				end
			end
		end
	end
end

buffActivatedEvent.OnClientEvent:Connect(function(potionType, endTime)
	activeBuffs[potionType] = endTime
end)

-- Load existing buffs on join
LoadExistingBuffs()

-- Start the timer update loop
task.spawn(UpdateTimers)