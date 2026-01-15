local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)
-- CarConfigs ya no se usa para ExpBase (ahora es un stat del jugador)

-- Esperar al RemoteEvent
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local expGainedEvent = remoteEvents:WaitForChild("ExpGainedEvent")

-- CONFIGURACIÓN
local INTERVALO = 0.1 -- Segundos para ganar EXP (10 veces por segundo)

local function CleanupPlayer(player)
	-- Ya no necesitamos limpiar posiciones
end

Players.PlayerRemoving:Connect(CleanupPlayer)

while true do
	task.wait(INTERVALO)
	
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		
		if character and character:FindFirstChild("Humanoid") then
			local humanoid = character.Humanoid

			-- DEBUG: Descomentar para diagnosticar
			-- if humanoid.MoveDirection.Magnitude == 0 then
			-- 	print("[WalkTraining DEBUG] " .. player.Name .. " MoveDirection = 0")
			-- end

			-- Verificar si está vivo y moviéndose
			if humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
				-- [[ LÓGICA DE CÁLCULO - HÍBRIDO ]] --

				-- 1. Obtener ExpBase desde el perfil del jugador (ya no depende del coche)
				local baseExp = DataManager.GetStat(player, "ExpBase") or 1

				-- 2. Obtener Multiplicador de Rebirth
				local rebirths = DataManager.GetStat(player, "Rebirths") or 0
				local rebirthMult = rebirths * 0.5 + 1

				-- 3. Obtener Multiplicador de Velocidad (convertido a boost aditivo)
				local speedMult = DataManager.GetStat(player, "Multiplier") or 1
				local speedBoost = speedMult - 1  -- 2x → +1, 4x → +3, etc.

				-- FÓRMULA HÍBRIDA: (Base * Rebirth) × (1 + Sum of Boosts)
				local baseValue = baseExp * rebirthMult
				local finalExp = baseValue * (1 + speedBoost)

				-- Apply SpeedPotion multiplier
				local speedRemaining = DataManager.GetStat(player, "SpeedPotionRemaining") or 0
				local expMultiplier = (speedRemaining > 0) and 2 or 1
				if expMultiplier > 1 then
					print("SpeedPotion active for " .. player.Name .. " in WalkTraining, remaining: " .. speedRemaining .. ", multiplier: " .. expMultiplier)
				end
				finalExp = finalExp * expMultiplier

				DataManager.AddStat(player, "EXP", finalExp)
				DataManager.AddStat(player, "TotalEXP", finalExp)
				DataManager.CheckLevelUp(player)

				-- Notificar al cliente la EXP ganada
				expGainedEvent:FireClient(player, finalExp)

				-- [[ FIN LÓGICA ]] --
			end
		end
	end
end