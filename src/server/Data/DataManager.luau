local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = {}

DataManager.Profiles = {}

-- Esperar a que exista el RemoteEvent (creado por RemoteEventsInit)
local function getEfectoLvlUpEvent()
	local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if remoteEventsFolder then
		return remoteEventsFolder:WaitForChild("EfectoLvlUp", 10)
	end
	return nil
end

-- Calcula la EXP necesaria para subir de nivel
local function GetRequiredExp(level: number)
	return level * 100
end

-- Calcula la velocidad del personaje basada en el nivel
local function CalculateWalkSpeed(level: number)
	return 16 + (level * 2)
end

-- Calcula el nivel máximo según los rebirths
local function GetMaxLevel(rebirths: number)
	return 20 + (rebirths * 10)
end

function DataManager.UpdateStat(player: Player, statName: string, newValue: any)
	local profile = DataManager.Profiles[player]
	if not profile then
		return
	end

	profile.Data[statName] = newValue

	-- Actualizar leaderstats si existe
	if statName == "EXP" or statName == "Level" or statName == "Rebirths" or statName == "Wins" then
		local ls = player:FindFirstChild("leaderstats")
		if ls then
			local statObj = ls:FindFirstChild(statName)
			if statObj then
				statObj.Value = newValue
			end
		end
	end

	-- Si cambia el nivel, actualizar velocidad del personaje
	if statName == "Level" and player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = CalculateWalkSpeed(newValue)
		end
	end
end

function DataManager.AddStat(player: Player, statName: string, amount: number)
	local profile = DataManager.Profiles[player]
	if profile and profile.Data[statName] ~= nil then
		DataManager.UpdateStat(player, statName, profile.Data[statName] + amount)
	end
end

function DataManager.GetStat(player: Player, statName: string)
	local profile = DataManager.Profiles[player]
	return profile and profile.Data[statName] or nil
end

-- Verifica si el jugador puede subir de nivel y lo hace automáticamente
-- Retorna: número de niveles subidos
function DataManager.CheckLevelUp(player: Player): number
	local profile = DataManager.Profiles[player]
	if not profile then
		return 0
	end

	local currentExp = profile.Data.EXP
	local currentLevel = profile.Data.Level
	local currentRebirths = profile.Data.Rebirths
	local maxLevel = GetMaxLevel(currentRebirths)
	local requiredExp = GetRequiredExp(currentLevel)
	local levelsGained = 0

	-- Permitir subir múltiples niveles en un solo tick
	while currentExp >= requiredExp and currentLevel < maxLevel do
		currentExp = currentExp - requiredExp
		currentLevel = currentLevel + 1
		levelsGained = levelsGained + 1
		requiredExp = GetRequiredExp(currentLevel)

		print("✨ " .. player.Name .. " subió al nivel " .. currentLevel .. "!")
		
		-- Disparar efecto visual de nivel a todos los clientes
		local efectoEvent = getEfectoLvlUpEvent()
		if efectoEvent and player.Character then
			efectoEvent:FireAllClients(player.Character, currentLevel)
		end
	end

	-- Si alcanzó el nivel máximo, mantener la EXP pero no permitir más niveles
	if currentLevel >= maxLevel then
		currentLevel = maxLevel
		if levelsGained > 0 then
			warn(
				"🏆 "
					.. player.Name
					.. " alcanzó el nivel MÁXIMO ("
					.. maxLevel
					.. ") para su Rebirth actual. ¡Haz Rebirth para desbloquear más niveles!"
			)
		end
	end

	-- Actualizar valores finales
	if currentLevel ~= profile.Data.Level then
		DataManager.UpdateStat(player, "Level", currentLevel)
	end
	if currentExp ~= profile.Data.EXP then
		DataManager.UpdateStat(player, "EXP", currentExp)
	end

	return levelsGained
end

return DataManager
