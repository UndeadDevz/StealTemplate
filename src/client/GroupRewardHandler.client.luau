-- GroupRewardHandler: Maneja el modal de recompensa por unirse al grupo
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GroupsService = game:GetService("GroupService")
local AvatarEditorService = game:GetService("AvatarEditorService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuración
local GROUP_ID = 1035894336
local PLACE_ID = game.PlaceId

-- Esperar a que existan los elementos de UI
local recompensaGui = playerGui:WaitForChild("RecompensaGratisGui")
local mainFrame = recompensaGui:WaitForChild("MainFrame")
local claimBtn = mainFrame:WaitForChild("ClaimBtn")
local closeBtn = mainFrame:WaitForChild("CloseBtn")
local likeButton = mainFrame:WaitForChild("LikeButton")
local joinGroupButton = mainFrame:WaitForChild("JoinGroupButton")

-- RemoteFunction para reclamar recompensa
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local claimGroupReward = remoteEvents:WaitForChild("ClaimGroupReward")

local isProcessing = false

-- ========== LIKE BUTTON ==========
likeButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local success, err = pcall(function()
			AvatarEditorService:PromptSetFavorite(PLACE_ID, Enum.AvatarItemType.Asset, true)
		end)

		if not success then
			warn("[GroupRewardHandler] Error al promptear favorito: " .. tostring(err))
		end
	end
end)

-- ========== JOIN GROUP BUTTON ==========
joinGroupButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local success, result = pcall(function()
			return GroupsService:PromptJoinAsync(GROUP_ID)
		end)

		if success then
			if result == Enum.GroupMembershipStatus.Joined then
				print("[GroupRewardHandler] Usuario se unió al grupo!")
			elseif result == Enum.GroupMembershipStatus.AlreadyMember then
				print("[GroupRewardHandler] Usuario ya es miembro del grupo")
			elseif result == Enum.GroupMembershipStatus.JoinRequestPending then
				print("[GroupRewardHandler] Solicitud de unión pendiente")
			end
		else
			warn("[GroupRewardHandler] Error al promptear grupo: " .. tostring(result))
		end
	end
end)

-- ========== CLAIM BUTTON ==========
claimBtn.MouseButton1Click:Connect(function()
	if isProcessing then return end
	isProcessing = true

	local originalText = claimBtn.Text
	claimBtn.Text = "..."

	local result = claimGroupReward:InvokeServer()

	if result.success then
		claimBtn.Text = "Claimed!"
		claimBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

		task.delay(1.5, function()
			mainFrame.Visible = false
		end)
	elseif result.alreadyClaimed then
		claimBtn.Text = "Already Claimed"
		claimBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	elseif not result.inGroup then
		claimBtn.Text = "Join Group First!"
		claimBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
	else
		claimBtn.Text = result.message or "Error"
	end

	task.delay(2, function()
		isProcessing = false
		if not result.success and not result.alreadyClaimed then
			claimBtn.Text = originalText
		end
	end)
end)

-- ========== CLOSE BUTTON ==========
closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

print("[GroupRewardHandler] Listo")
