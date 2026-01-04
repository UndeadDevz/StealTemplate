local Players = game:GetService("Players")
local DataManager = require(script.Parent.Parent.Data.DataManager)

while true do
	task.wait(1)
	
	local zonasEXP = workspace:FindFirstChild("ZonasEXP")
	if not zonasEXP then
		warn("[ExpTraining] ⚠️ Falta la carpeta 'ZonasEXP' en Workspace.")
		task.wait(10)
		continue
	end
	
	for _, zona in pairs(zonasEXP:GetChildren()) do
		if not zona:IsA("BasePart") then continue end
		
		local parts = workspace:GetPartsInPart(zona)
		local procesados = {}

		for _, part in pairs(parts) do
			local player = Players:GetPlayerFromCharacter(part.Parent)
			if player and not procesados[player.Name] then
				procesados[player.Name] = true
				
				-- Obtener estadísticas de forma segura usando DataManager
				local level = DataManager.GetStat(player, "Level") or 1
				local rebirths = DataManager.GetStat(player, "Rebirths") or 0
				local maxLevel = 20 + (rebirths * 10)
				
				if level < maxLevel then
					-- [[ NUEVA LÓGICA DE CÁLCULO ]] --

					-- 1. Obtener Base (EquipType)
					local baseExp = DataManager.GetStat(player, "EquipType") or 1
					
					-- 2. Obtener Multiplicador de Zona (El atributo del cubo)
					-- Si el cubo no tiene atributo, asumimos multiplicador x1
					local zonaMult = zona:GetAttribute("ExpBase") or 1
					
					-- 3. Obtener Multiplicador de Rebirth
					local rebirthMult = rebirths * 0.5 + 1
					local speedMult = DataManager.GetStat(player, "Multiplier") or 1
					
					-- FÓRMULA FINAL: Base * Zona * Rebirth
					local expGanada = baseExp * zonaMult * rebirthMult * speedMult
					
					-- [[ FIN NUEVA LÓGICA ]] --
					
					DataManager.AddStat(player, "EXP", expGanada)
					DataManager.AddStat(player, "TotalEXP", expGanada)
					DataManager.CheckLevelUp(player)
				end
			end
		end
	end
end