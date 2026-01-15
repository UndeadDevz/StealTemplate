local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Assume InventoryFrame exists in MainUI
local mainUI = playerGui:WaitForChild("MainUI")
local inventoryFrame = mainUI:WaitForChild("InventoryFrame")

local remoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local usePotion = remoteFunctions:WaitForChild("UsePotion",5)
local getStat = remoteEvents:WaitForChild("GetStat",5)

-- Assume buttons: UseSpeedPotionButton, UseWinPotionButton
local speedButton = inventoryFrame:FindFirstChild("UseSpeedPotionButton",true)
local winsButton = inventoryFrame:FindFirstChild("UseWinPotionButton",true)

local function UpdateCounts()
	local speedCount = getStat:InvokeServer("SpeedPotionCount") or 0
	local winsCount = getStat:InvokeServer("WinsPotionCount") or 0
	
	local speedCountLabel = speedButton:FindFirstChild("Count")
	if speedCountLabel then
		speedCountLabel.Text = "(" .. speedCount .. ")"
	end
	
	local winsCountLabel = winsButton:FindFirstChild("Count")
	if winsCountLabel then
		winsCountLabel.Text = "(" .. winsCount .. ")"
	end
	
end

speedButton.MouseButton1Click:Connect(function()
	local success = usePotion:InvokeServer("SpeedPotion")
	if success then
		UpdateCounts()
	end
end)

winsButton.MouseButton1Click:Connect(function()
	local success = usePotion:InvokeServer("WinsPotion")
	if success then
		UpdateCounts()
	end
end)

-- Update on open
inventoryFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if inventoryFrame.Visible then
		UpdateCounts()
	end
end)