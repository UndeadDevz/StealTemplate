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

	DOS TIPOS DE REBIRTH:
	1. Rebirth Normal (Gratis):
	   - Resetea nivel a 1
	   - Resetea EXP a 0
	   - Resetea velocidad a base

	2. Rebirth Keep Level (Developer Product):
	   - Requiere comprar el producto "Rebirth Keep Level"
	   - Mantiene tu nivel y EXP
	   - Solo aumenta el contador de Rebirths

	═══════════════════════════════════════════════════════════════════════
]]

-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- ========== CONFIGURACIÓN ==========
local REBIRTH_KEEP_LEVEL_PRODUCT_ID = 3505671943 -- ⚠️ REEMPLAZAR CON EL ID DEL DEVELOPER PRODUCT
-- ===================================

-- Rebirth NORMAL (Gratis) - Resetea nivel
local function RebirthNormal(player: Player)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return false end

	local level = stats:FindFirstChild("Level")
	local rebirths = stats:FindFirstChild("Rebirths")

	if not level or not rebirths then return false end

	local rebirthsActuales = rebirths.Value
	local nivelRequerido = 25 + (rebirthsActuales * 25)

	if level.Value >= nivelRequerido then
		-- Realizar Rebirth RESETEANDO NIVEL
		DataManager.UpdateStat(player, "Rebirths", rebirthsActuales + 1)
		DataManager.UpdateStat(player, "Level", 1)
		DataManager.UpdateStat(player, "EXP", 0)
		DataManager.UpdateStat(player, "TotalEXP", 0) -- Resetear Speed/TotalEXP

		-- Resetear velocidad del personaje
		if player.Character then
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 4 -- Velocidad base
			end
		end

		print("✨ " .. player.Name .. " hizo Rebirth NORMAL! Rebirths: " .. (rebirthsActuales + 1) .. ", Nivel reseteado a 1")
		return true
	else
		warn("⚠️ " .. player.Name .. " no tiene suficiente nivel. Necesita: " .. nivelRequerido .. ", tiene: " .. level.Value)
		return false
	end
end

-- Rebirth KEEP LEVEL (Producto) - Mantiene nivel
-- Esta función solo hace el rebirth, la compra se maneja en MarketplaceManager
function RebirthKeepLevel(player: Player)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return false end

	local level = stats:FindFirstChild("Level")
	local rebirths = stats:FindFirstChild("Rebirths")

	if not level or not rebirths then return false end

	local rebirthsActuales = rebirths.Value
	local nivelRequerido = 25 + (rebirthsActuales * 25)

	if level.Value >= nivelRequerido then
		-- Realizar Rebirth SIN PERDER NIVEL
		DataManager.UpdateStat(player, "Rebirths", rebirthsActuales + 1)
		-- NO resetea Level ni EXP - el jugador mantiene su progreso!

		print("🌟 " .. player.Name .. " hizo Rebirth KEEP LEVEL! Nivel: " .. level.Value .. ", Rebirths: " .. (rebirthsActuales + 1))
		return true
	else
		warn("⚠️ " .. player.Name .. " no tiene suficiente nivel. Necesita: " .. nivelRequerido .. ", tiene: " .. level.Value)
		return false
	end
end

-- Exportar para que MarketplaceManager pueda usarlo
_G.RebirthKeepLevel = RebirthKeepLevel

-- Conectar al RemoteEvent para el botón UI
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local requestRebirth = remoteEvents:WaitForChild("RequestRebirth")

-- Tabla para cooldown de solicitudes
local rebirthCooldowns = {}

-- Handler para Rebirth NORMAL (gratis)
requestRebirth.OnServerEvent:Connect(function(player)
	-- Cooldown simple para evitar múltiples rebirths accidentales
	local lastRebirth = rebirthCooldowns[player.UserId] or 0
	local now = tick()

	if now - lastRebirth > 2 then -- 2 segundos de cooldown
		rebirthCooldowns[player.UserId] = now
		RebirthNormal(player)
	else
		warn("⚠️ " .. player.Name .. " debe esperar antes de hacer otro Rebirth")
	end
end)

-- Handler para Rebirth KEEP LEVEL (requiere compra de producto)
local requestRebirthKeepLevel = remoteEvents:WaitForChild("RequestRebirthKeepLevel")

requestRebirthKeepLevel.OnServerEvent:Connect(function(player)
	if REBIRTH_KEEP_LEVEL_PRODUCT_ID == 0 then
		warn("[RebirthSystem] REBIRTH_KEEP_LEVEL_PRODUCT_ID no configurado")
		return
	end

	-- Mostrar prompt de compra
	MarketplaceService:PromptProductPurchase(player, REBIRTH_KEEP_LEVEL_PRODUCT_ID)
end)

-- Limpiar cooldowns cuando el jugador se va
Players.PlayerRemoving:Connect(function(player)
	rebirthCooldowns[player.UserId] = nil
end)

print("[RebirthSystem] ✅ Sistema de Rebirth activado (UI Button)")
