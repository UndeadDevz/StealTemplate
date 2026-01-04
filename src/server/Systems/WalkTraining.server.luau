local Players = game:GetService("Players")
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- CONFIGURACIÓN
local INTERVALO = 1          -- Segundos para ganar EXP
local UMBRAL_MOVIMIENTO = 0.5 -- Distancia mínima para contar como "caminar"

local lastPositions = {}



local function CleanupPlayer(player)
	lastPositions[player] = nil
end

Players.PlayerRemoving:Connect(CleanupPlayer)

while true do
	task.wait(INTERVALO)
	
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		
		if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
			local humanoid = character.Humanoid
			local rootPart = character.HumanoidRootPart
			
			if humanoid.Health > 0 then
				local currentPos = rootPart.Position
				local lastPos = lastPositions[player]
				
				if lastPos then
					local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(lastPos.X, 0, lastPos.Z)).Magnitude
					
					if dist > UMBRAL_MOVIMIENTO and dist < 100 then
						-- [[ NUEVA LÓGICA DE CÁLCULO ]] --
						
						-- 1. Obtener Base (EquipType)
						-- Si es 0 o nil, usamos 1 para que al menos gane algo
						local baseExp = DataManager.GetStat(player, "EquipType") or 1
						local speedMult = DataManager.GetStat(player, "Multiplier") or 1
						
						-- 2. Obtener Multiplicador de Rebirth
						local rebirths = DataManager.GetStat(player, "Rebirths") or 0
					local rebirthMult = rebirths * 0.5 + 1
						print(rebirthMult, baseExp, speedMult)
						-- 3. Calcular Total
						-- Fórmula: Base (Herramienta) * Rebirths
						local finalExp = baseExp * rebirthMult * speedMult
						
						DataManager.AddStat(player, "EXP", finalExp)
					DataManager.AddStat(player, "TotalEXP", finalExp)
				end
				
				lastPositions[player] = currentPos
			else
				lastPositions[player] = nil
			end
		end
	end
end