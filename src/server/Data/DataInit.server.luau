-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")
local WinsLeaderboardStore = DataStoreService:GetOrderedDataStore("GlobalWins_v1")
local SpeedLeaderboardStore = DataStoreService:GetOrderedDataStore("GlobalSpeed_v1")

--ProfileStore
local ProfileStore = require(ServerScriptService.Libraries:WaitForChild("ProfileStore"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function GetStoreName()
	return RunService:IsStudio() and "Test1" or "Live"
end

local Template = require(ServerScriptService.Data.Template)
local DataManager = require(ServerScriptService.Data.DataManager)
local ExpBaseConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ExpBaseConfig"))

--Acess profile store
local PlayerStore = ProfileStore.New(GetStoreName(), Template)

-- Migrar datos de jugadores legacy (antes del sistema ExpBase separado)
local function MigrateLegacyData(profile, player)
	local data = profile.Data

	-- Detectar si es un jugador legacy (no tiene ExpBaseLevel o UnlockedCarsuits)
	local isLegacyPlayer = data.ExpBaseLevel == nil or data.UnlockedCarsuits == nil

	if isLegacyPlayer then
		local oldEquipType = data.EquipType or 1

		-- Mapeo de EquipType antiguo -> ExpBaseLevel
		-- (El EquipType determinaba el ExpBase, ahora es un stat separado)
		local equipTypeToExpBaseLevel = {
			[1] = 1, [2] = 2, [3] = 3, [4] = 4,
			[5] = 5, [6] = 6, [7] = 7, [8] = 8,
			[9] = 8 -- SharkTruck tenia ExpBase 50000, asignamos nivel 8 (500)
		}

		-- Migrar ExpBase
		local newExpBaseLevel = equipTypeToExpBaseLevel[oldEquipType] or 1
		data.ExpBaseLevel = newExpBaseLevel
		data.ExpBase = ExpBaseConfig.GetExpBaseValue(newExpBaseLevel)

		-- Migrar UnlockedCarsuits (desbloquear todos hasta el EquipType actual)
		data.UnlockedCarsuits = {}
		for i = 1, oldEquipType do
			table.insert(data.UnlockedCarsuits, i)
		end

		print("[Migration] Jugador legacy migrado: " .. player.Name)
		print("  - OldEquipType: " .. oldEquipType)
		print("  - NewExpBaseLevel: " .. newExpBaseLevel)
		print("  - NewExpBase: " .. data.ExpBase)
		print("  - UnlockedCarsuits: " .. table.concat(data.UnlockedCarsuits, ", "))
	end
end

-- Calcula la velocidad del personaje basada en el nivel
local function CalculateWalkSpeed(level: number)
	return 4 + (level * 2)
end

-- Actualiza la velocidad del personaje respetando CustomSpeed
local function UpdateCharacterSpeed(player: Player, character, level: number)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local profile = DataManager.Profiles[player]
		local maxSpeed = CalculateWalkSpeed(level)
		
		if profile then
			local customSpeed = profile.Data.CustomSpeed or 0
			
			-- Si CustomSpeed es 0 o mayor al máximo, usar el máximo
			-- Si no, usar la velocidad personalizada (clampeada al máximo)
			if customSpeed == 0 or customSpeed > maxSpeed then
				humanoid.WalkSpeed = maxSpeed
			else
				humanoid.WalkSpeed = math.clamp(customSpeed, 1, maxSpeed)
			end
		else
			humanoid.WalkSpeed = maxSpeed
		end
	end
end

-- Add leaderstats y configura velocidad del personaje
local function Initialize(player: Player, profile: typeof(PlayerStore:StartSessionAsync()))
	-- Leaderstats
	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"

	local Level = Instance.new("IntValue", leaderstats)
	Level.Name = "Level"
	Level.Value = profile.Data.Level

	local Rebirths = Instance.new("IntValue", leaderstats)
	Rebirths.Name = "Rebirths"
	Rebirths.Value = profile.Data.Rebirths

	local Wins = Instance.new("IntValue", leaderstats)
	Wins.Name = "Wins"
	Wins.Value = profile.Data.Wins

	local Speed = Instance.new("NumberValue", leaderstats)
	Speed.Name = "Speed"
	Speed.Value = profile.Data.TotalEXP

	-- Conectar evento de cambio de nivel para actualizar velocidad
	Level.Changed:Connect(function(newLevel)
		if player.Character then
			UpdateCharacterSpeed(player, player.Character, newLevel)
		end
	end)

	-- Aplicar velocidad cuando el personaje spawns/respawns
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid") -- Esperar a que exista el Humanoid
		UpdateCharacterSpeed(player, character, Level.Value)
	end)

	-- Aplicar velocidad al personaje actual si ya existe
	if player.Character then
		UpdateCharacterSpeed(player, player.Character, Level.Value)
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

		-- Migrar datos de jugadores legacy
		MigrateLegacyData(profile, player)

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
	pcall(function()
		WinsLeaderboardStore:SetAsync(player.UserId, math.floor(profile.Data.Wins))
		SpeedLeaderboardStore:SetAsync(player.UserId, math.floor(profile.Data.TotalEXP))
	end)

	profile:EndSession()
	DataManager.Profiles[player] = nil
end)

-- Actualizar OrderedDataStore periódicamente para todos los jugadores
local LEADERBOARD_UPDATE_INTERVAL = 60 -- segundos

task.spawn(function()
	while true do
		task.wait(LEADERBOARD_UPDATE_INTERVAL)

		for _, player in Players:GetPlayers() do
			local profile = DataManager.Profiles[player]
			if profile then
				task.spawn(function()
					pcall(function()
						WinsLeaderboardStore:SetAsync(player.UserId, math.floor(profile.Data.Wins))
						SpeedLeaderboardStore:SetAsync(player.UserId, math.floor(profile.Data.TotalEXP))
					end)
				end)
			end
		end
	end
end)
