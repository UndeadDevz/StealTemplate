local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = {}

DataManager.Profiles = {}

local function getExpEffectEvent()
	local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
	if remoteEventsFolder then
		return remoteEventsFolder:WaitForChild("ExpEffectEvent")
	end
	return nil
end

-- Esperar a que exista el RemoteEvent (creado por RemoteEventsInit)
local function getEfectoLvlUpEvent()
	local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if remoteEventsFolder then
		return remoteEventsFolder:WaitForChild("EfectoLvlUp", 10)
	end
	return nil
end

-- Calcula la EXP necesaria para subir de nivel
-- Sistema de 3 fases: Lineal → Transición → Exponencial
local function GetRequiredExp(level: number)
	if level <= 25 then
		-- FASE 1: Tutorial (Lineal) - Niveles 0-25
		-- Crecimiento de ~13 puntos por nivel
		return math.floor(51 + (level * 13))

	elseif level <= 50 then
		-- FASE 2A: Transición Temprana (Ratio 1.05) - Niveles 26-50
		-- Los números empiezan a multiplicarse suavemente
		return math.floor(373 * (1.05 ^ (level - 25)))

	elseif level <= 75 then
		-- FASE 2B: Transición Media (Ratio 1.10) - Niveles 51-75
		-- La curva empieza a empinarse
		return math.floor(2120 * (1.10 ^ (level - 50)))

	else
		-- FASE 3: Muro Exponencial (Ratio 1.15) - Niveles 76+
		-- Cada 5 niveles la EXP se duplica
		-- Nivel 100 = 1.17M, Nivel 105 = 2.36M
		return math.floor(35650 * (1.15 ^ (level - 75)))
	end
end

-- Calcula la velocidad del personaje basada en el nivel
local function CalculateWalkSpeed(level: number)
	return 1 + (level * 2)
end

-- Calcula el nivel máximo según los rebirths (Hard cap at 375)
local function GetMaxLevel(rebirths: number)
	local calculatedMax = 25 + (rebirths * 25)  -- Every 25 levels
	return math.min(calculatedMax, 375)  -- Hard cap at 375
end

function DataManager.UpdateStat(player: Player, statName: string, newValue: any)
	local profile = DataManager.Profiles[player]
	if not profile then
		return
	end
	profile.Data[statName] = newValue

	-- Actualizar leaderstats si existe
	if statName == "EXP" or statName == "Level" or statName == "Rebirths" or statName == "Wins" or statName == "Multiplier" then
		local ls = player:FindFirstChild("leaderstats")
		if ls then
			local statObj = ls:FindFirstChild(statName)
			if statObj then
				statObj.Value = newValue
			end
		end
	end

	-- Si cambia el nivel, actualizar velocidad del personaje respetando la velocidad personalizada
	if statName == "Level" and player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid then
			local maxSpeed = CalculateWalkSpeed(newValue)
			local customSpeed = profile.Data.CustomSpeed or 0
			
			-- Si CustomSpeed es 0 o mayor al nuevo máximo, usar el máximo
			-- Si no, usar la velocidad personalizada (clampeada al nuevo máximo)
			if customSpeed == 0 or customSpeed > maxSpeed then
				humanoid.WalkSpeed = maxSpeed
			else
				humanoid.WalkSpeed = math.clamp(customSpeed, 1, maxSpeed)
			end
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

-- Obtiene las configuraciones del jugador
function DataManager.GetSettings(player: Player)
	local profile = DataManager.Profiles[player]
	if not profile then
		return nil
	end
	return profile.Data.Settings
end

-- Actualiza las configuraciones del jugador
function DataManager.UpdateSettings(player: Player, settings: {[string]: any})
	local profile = DataManager.Profiles[player]
	if not profile then
		return false
	end

	-- Actualizar cada configuración
	for key, value in pairs(settings) do
		if profile.Data.Settings[key] ~= nil then
			profile.Data.Settings[key] = value
		end
	end

	return true
end

function DataManager.UnlockTrack(player: Player, trackValue: number)
	local profile = DataManager.Profiles[player]
	if not profile then return end
	
	-- Asegurarse de que la tabla Tracks existe
	if not profile.Data.Tracks then
		profile.Data.Tracks = {}
	end

	-- Verificar si ya la tiene para no duplicar
	local alreadyHas = false
	for _, v in pairs(profile.Data.Tracks) do
		if v == trackValue then
			alreadyHas = true
			break
		end
	end

	if not alreadyHas then
		table.insert(profile.Data.Tracks, trackValue)
		print("🔓 " .. player.Name .. " desbloqueó la zona x" .. trackValue)
	end
end

return DataManager
