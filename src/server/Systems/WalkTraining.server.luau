local Players = game:GetService("Players")
local DataManager = require(script.Parent.Parent.Data.DataManager)

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
			
			-- Verificar si está vivo y moviéndose
			if humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
				-- [[ LÓGICA DE CÁLCULO ]] --
				
				-- 1. Obtener Base (EquipType)
				local baseExp = DataManager.GetStat(player, "EquipType") or 1
				local speedMult = DataManager.GetStat(player, "Multiplier") or 1
				
				-- 2. Obtener Multiplicador de Rebirth
				local rebirths = DataManager.GetStat(player, "Rebirths") or 0
				local rebirthMult = rebirths * 0.5 + 1
				
				-- 3. Calcular Total
				-- Fórmula: Base (Herramienta) * Rebirth * Speed
				local finalExp = baseExp * rebirthMult * speedMult
				
				DataManager.AddStat(player, "EXP", finalExp)
				DataManager.AddStat(player, "TotalEXP", finalExp)
				DataManager.CheckLevelUp(player)
				
				-- [[ FIN LÓGICA ]] --
			end
		end
	end
end