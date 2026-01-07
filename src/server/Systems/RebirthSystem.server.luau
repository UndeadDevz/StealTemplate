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

	GAMEPASS x2 Wins:
	- Al hacer Rebirth, NO pierdes tu nivel ni EXP
	- Sigues requiriendo el nivel mínimo para hacer Rebirth
	- Sin GamePass: pierdes todo y vuelves a nivel 1
	
	═══════════════════════════════════════════════════════════════════════
]]

-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- Modules
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- ========== CONFIGURACIÓN ==========
local X2_WINS_GAMEPASS_ID = 1694367675565474295 -- GamePass "x2 Wins"
-- ===================================

-- Cache para GamePass
local gamePassCache = {}

-- Función para verificar si el jugador tiene el GamePass x2 Wins
local function PlayerHasX2Wins(player)
	if X2_WINS_GAMEPASS_ID == 0 then
		return false
	end

	-- Verificar en cache primero
	if gamePassCache[player.UserId] ~= nil then
		return gamePassCache[player.UserId]
	end

	-- Verificar con la API de Roblox
	local success, ownsPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, X2_WINS_GAMEPASS_ID)
	end)

	if success then
		gamePassCache[player.UserId] = ownsPass
		return ownsPass
	else
		warn("[RebirthSystem] Error al verificar GamePass:", ownsPass)
		return false
	end
end

-- Intenta hacer Rebirth para un jugador
local function IntentarRebirth(player: Player)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return false end

	local level = stats:FindFirstChild("Level")
	local rebirths = stats:FindFirstChild("Rebirths")

	if not level or not rebirths then return false end

	local rebirthsActuales = rebirths.Value

	-- Verificar si tiene el GamePass x2 Wins
	local hasX2Pass = PlayerHasX2Wins(player)

	-- REGLA: Cada rebirth pide 25 niveles más que el anterior
	-- Rebirth 0 pide Nivel 25, Rebirth 1 pide Nivel 50, etc.
	local nivelRequerido = 25 + (rebirthsActuales * 25)

	-- Si tiene el GamePass, NO PIERDE NIVELES al hacer rebirth
	if hasX2Pass then
		-- Verificar requisito de nivel normal
		local nivelRequerido = 25 + (rebirthsActuales * 25)

		if level.Value >= nivelRequerido then
			-- Realizar Rebirth SIN PERDER NIVEL
			DataManager.UpdateStat(player, "Rebirths", rebirthsActuales + 1)
			-- NO resetea Level ni EXP - el jugador mantiene su progreso!

			print("🌟 " .. player.Name .. " hizo Rebirth SIN PERDER NIVEL (x2 Wins GamePass)! Nivel: " .. level.Value .. ", Rebirths: " .. (rebirthsActuales + 1))
			return true
		else
			warn("⚠️ " .. player.Name .. " necesita nivel " .. nivelRequerido .. " para hacer Rebirth. Tiene: " .. level.Value)
			warn("💡 Con el GamePass x2 Wins, NO pierdes tus niveles al hacer Rebirth!")
			return false
		end
	else
		-- Sin GamePass, PIERDE NIVELES al hacer rebirth
		if level.Value >= nivelRequerido then
			-- Realizar Rebirth RESETEANDO NIVEL
			DataManager.UpdateStat(player, "Rebirths", rebirthsActuales + 1)
			DataManager.UpdateStat(player, "Level", 1)
			DataManager.UpdateStat(player, "EXP", 0)

			-- Resetear velocidad del personaje
			if player.Character then
				local humanoid = player.Character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = 4 -- Velocidad base
				end
			end

			print("✨ " .. player.Name .. " hizo Rebirth! Rebirths: " .. (rebirthsActuales + 1) .. ", Nivel reseteado a 1")
			return true
		else
			warn("⚠️ " .. player.Name .. " no tiene suficiente nivel. Necesita: " .. nivelRequerido .. ", tiene: " .. level.Value)
			warn("💡 TIP: Con el GamePass x2 Wins, NO pierdes tus niveles al hacer Rebirth!")
			return false
		end
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
