--[[
	═══════════════════════════════════════════════════════════════════════
	INSTRUCCIONES DE CONFIGURACIÓN DEL WORKSPACE
	═══════════════════════════════════════════════════════════════════════
	
	Para que el sistema de Rebirth funcione, necesitas crear una parte
	en el Workspace donde los jugadores puedan hacer Rebirth:
	
	1. CREAR PARTE DE REBIRTH:
	   - En Workspace, crea una Part llamada "ParteRebirth"
	   - Propiedades sugeridas:
	     * BrickColor = Bright red (o el color que prefieras)
	     * Material = Neon (para que brille y sea visible)
	     * CanCollide = true (para que los jugadores la toquen)
	     * Anchored = true (para que no se mueva)
	     * Size = Vector3.new(10, 1, 10) (ajusta según prefieras)
	   
	2. POSICIONAR LA PARTE:
	   - Colócala en un lugar visible y accesible
	   - Considera ponerla en el spawn o en un área central
	   
	3. OPCIONAL - AGREGAR TEXTO:
	   - Agrega un SurfaceGui con un TextLabel que diga:
	     "REBIRTH - Toca para reiniciar tu nivel y multiplicar tu EXP"
	
	REQUISITOS DE REBIRTH:
	- Rebirth 0 → Requiere Nivel 25
	- Rebirth 1 → Requiere Nivel 50
	- Rebirth 2 → Requiere Nivel 75
	- Y así sucesivamente (+25 niveles por cada Rebirth)
	- Hard cap: Nivel 375
	
	BENEFICIOS:
	- Cada Rebirth multiplica la ganancia de EXP
	- Rebirth 0: EXP x1
	- Rebirth 1: EXP x2
	- Rebirth 2: EXP x3
	- Etc.
	
	═══════════════════════════════════════════════════════════════════════
]]

-- Services
local Players = game:GetService("Players")

-- Modules
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- Intenta hacer Rebirth para un jugador
local function IntentarRebirth(player: Player)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return false end
	
	local level = stats:FindFirstChild("Level")
	local rebirths = stats:FindFirstChild("Rebirths")
	
	if not level or not rebirths then return false end
	
	local rebirthsActuales = rebirths.Value

	-- REGLA: Cada rebirth pide 25 niveles más que el anterior
	-- Rebirth 0 pide Nivel 25, Rebirth 1 pide Nivel 50, etc.
	local nivelRequerido = 25 + (rebirthsActuales * 25)
	
	if level.Value >= nivelRequerido then
		-- Realizar Rebirth
		DataManager.UpdateStat(player, "Rebirths", rebirthsActuales + 1)
		DataManager.UpdateStat(player, "Level", 1)
		DataManager.UpdateStat(player, "EXP", 0)
		
		-- Resetear velocidad del personaje
		if player.Character then
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 16 -- Velocidad base
			end
		end
		
		print("✨ " .. player.Name .. " hizo Rebirth! Ahora tiene " .. (rebirthsActuales + 1) .. " Rebirths")
		return true
	else
		warn("⚠️ " .. player.Name .. " no tiene suficiente nivel. Necesita: " .. nivelRequerido .. ", tiene: " .. level.Value)
		return false
	end
end

-- Esperar a que exista la ParteRebirth
local parteRebirth = workspace:WaitForChild("ParteRebirth", 30)

if not parteRebirth then
	warn("[RebirthSystem] ❌ No se encontró 'ParteRebirth' en Workspace. Por favor créala siguiendo las instrucciones del script.")
else
	print("[RebirthSystem] ✅ Sistema de Rebirth activado")
	
	-- Conectar evento de toque
	parteRebirth.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			-- Cooldown simple para evitar múltiples rebirths accidentales
			local lastRebirth = parteRebirth:GetAttribute("LastRebirth_" .. player.UserId) or 0
			local now = tick()
			
			if now - lastRebirth > 2 then -- 2 segundos de cooldown
				parteRebirth:SetAttribute("LastRebirth_" .. player.UserId, now)
				IntentarRebirth(player)
			end
		end
	end)
end
