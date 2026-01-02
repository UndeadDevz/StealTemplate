-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

--ProfileStore
local ProfileStore = require(ServerScriptService.Libraries:WaitForChild("ProfileStore"))

local function GetStoreName()
	return RunService:IsStudio() and "Test" or "Live"
end

local Template = require(ServerScriptService.Data.Template)
local DataManager = require(ServerScriptService.Data.DataManager)

--Acess profile store
local PlayerStore = ProfileStore.New(GetStoreName(), Template)

-- Calcula la velocidad del personaje basada en el nivel
local function CalculateWalkSpeed(level: number)
	return 16 + (level * 2)
end

-- Actualiza la velocidad del personaje
local function UpdateCharacterSpeed(character, level: number)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = CalculateWalkSpeed(level)
	end
end

-- Add leaderstats y configura velocidad del personaje
local function Initialize(player: Player, profile: typeof(PlayerStore:StartSessionAsync()))
	-- Leaderstats
	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"

	local EXP = Instance.new("NumberValue", leaderstats)
	EXP.Name = "EXP"
	EXP.Value = profile.Data.EXP

	local Level = Instance.new("IntValue", leaderstats)
	Level.Name = "Level"
	Level.Value = profile.Data.Level

	local Rebirths = Instance.new("IntValue", leaderstats)
	Rebirths.Name = "Rebirths"
	Rebirths.Value = profile.Data.Rebirths

	local Wins = Instance.new("IntValue", leaderstats)
	Wins.Name = "Wins"
	Wins.Value = profile.Data.Wins

	-- Conectar evento de cambio de nivel para actualizar velocidad
	Level.Changed:Connect(function(newLevel)
		if player.Character then
			UpdateCharacterSpeed(player.Character, newLevel)
		end
	end)

	-- Aplicar velocidad cuando el personaje spawns/respawns
	player.CharacterAdded:Connect(function(character)
		UpdateCharacterSpeed(character, Level.Value)
	end)

	-- Aplicar velocidad al personaje actual si ya existe
	if player.Character then
		UpdateCharacterSpeed(player.Character, Level.Value)
	end
end

--Creates and stores a profile
local function PlayerAdded(player)
	--Start a new profile session
	local profile = PlayerStore:StartSessionAsync("Player_" .. player.UserId, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	--Sanity check to ensure profile exists
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile() -- fill in missing data in profile.Data from Template

		--Handle session-lacking
		profile.OnSessionEnd:Connect(function()
			DataManager.Profiles[player] = nil
			player:Kick("Data issue, try to rejoin")
		end)

		if player.parent == Players then
			DataManager.Profiles[player] = profile
			Initialize(player, profile)
		else
			profile:EndSession()
		end
	else
		player:Kick("Data issue, try to rejoin")
	end
end

--Early joiners
for _, player in Players:GetPlayers() do
	task.spawn(PlayerAdded, player)
end
Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = DataManager.Profiles[player]
	if not profile then
		return
	end
	profile:EndSession()
	DataManager.Profiles[player] = nil
end)
