--[[
	CarAvailabilityVisualizer
	Visualizes car availability by changing material colors based on player stats.

	Color Logic:
	- Green: Player has this EquipType equipped
	- Yellow: Player has enough wins to unlock this EquipType
	- Red: Player doesn't meet the requirements yet
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Wait for player data to be loaded (leaderstats is created when data is ready)
player:WaitForChild("leaderstats", 10)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local GetStat = RemoteEvents:WaitForChild("GetStat")

-- Color presets
local COLORS = {
	Green = Color3.fromRGB(0, 255, 0),
	Yellow = Color3.fromRGB(255, 255, 0),
	Red = Color3.fromRGB(255, 0, 0)
}

-- Get player stats with error handling
local function getPlayerStats()
	local success, wins = pcall(function()
		return GetStat:InvokeServer("Wins")
	end)

	local success2, equipType = pcall(function()
		return GetStat:InvokeServer("EquipType")
	end)

	-- Return nil if stats aren't loaded yet
	if not success or not success2 or wins == nil or equipType == nil then
		return nil, nil
	end

	return wins, equipType
end

-- Update a single car availability indicator
local function updateCarAvailability(part)
	local requiredWins = part:GetAttribute("Wins")
	local requiredEquipType = part:GetAttribute("EquipType")

	-- Validate attributes exist
	if not requiredWins or not requiredEquipType then
		warn("IsCarAvailable element missing Wins or EquipType attribute:", part:GetFullName())
		return
	end

	-- Get player stats
	local playerWins, playerEquipType = getPlayerStats()

	-- If stats aren't loaded yet, skip update (will retry later)
	if not playerWins or not playerEquipType then
		return
	end

	-- Determine color based on conditions
	local color
	if playerEquipType == requiredEquipType then
		-- Player already has this EquipType equipped
		color = COLORS.Green
	elseif playerWins >= requiredWins then
		-- Player has enough wins to unlock
		color = COLORS.Yellow
	else
		-- Player doesn't meet requirements
		color = COLORS.Red
	end

	-- Apply color to the part
	if part:IsA("BasePart") then
		part.Color = color
	end
end

-- Update all car availability indicators
local function updateAllCarAvailability()
	local carAvailabilityParts = CollectionService:GetTagged("IsCarAvailable")

	for _, part in carAvailabilityParts do
		updateCarAvailability(part)
	end
end

-- Initialize: wait a moment for data to be fully ready, then update all existing parts
task.wait(0.5)
updateAllCarAvailability()

-- Listen for new parts being added
CollectionService:GetInstanceAddedSignal("IsCarAvailable"):Connect(function(part)
	updateCarAvailability(part)
end)

-- Listen for stat changes (when player gains wins or changes EquipType)
local ChangeCarModel = RemoteEvents:FindFirstChild("ChangeCarModel")
if ChangeCarModel then
	ChangeCarModel.OnClientEvent:Connect(function()
		-- EquipType changed, update all indicators
		updateAllCarAvailability()
	end)
end

-- Listen for wins changes
local WinsChanged = RemoteEvents:WaitForChild("WinsChanged")
WinsChanged.OnClientEvent:Connect(function(newWins)
	-- Wins changed, update all indicators
	updateAllCarAvailability()
end)
