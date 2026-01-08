--[[
	═══════════════════════════════════════════════════════════════════════
	CHANGE CAR MODEL HANDLER - SISTEMA HÍBRIDO
	═══════════════════════════════════════════════════════════════════════

	Este script escucha cuando el servidor notifica un cambio de EquipType
	y decide dinámicamente si:
	- Cambiar texturas instantáneamente (sin reload)
	- Cambiar modelo completo (con reload)

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Importar módulos del sistema híbrido
local Shared = ReplicatedStorage:WaitForChild("Shared")
local CarConfigs = require(Shared:WaitForChild("CarConfigs"))
local CarCustomizationUtils = require(Shared:WaitForChild("CarCustomizationUtils"))

local player = Players.LocalPlayer
local character = script.Parent

-- Esperar al RemoteEvent
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local changeCarModel = remoteEvents:WaitForChild("ChangeCarModel")

-- ═══════════════════════════════════════════════════════════════════════
-- CACHÉ LOCAL DEL EQUIPTYPE ACTUAL
-- ═══════════════════════════════════════════════════════════════════════
-- Inicializar desde leaderstats si existe, sino usar default
local currentEquipTypeCache = 1
local leaderstats = player:WaitForChild("leaderstats", 5)
if leaderstats then
	local equipTypeStat = leaderstats:FindFirstChild("EquipType")
	if equipTypeStat then
		currentEquipTypeCache = equipTypeStat.Value
		print("[ChangeCarModel] EquipType inicial: " .. currentEquipTypeCache)
	end
end

-- ═══════════════════════════════════════════════════════════════════════
-- HANDLER DE CAMBIO DE EQUIPTYPE
-- ═══════════════════════════════════════════════════════════════════════
changeCarModel.OnClientEvent:Connect(function(targetPlayer, newEquipType)
	-- Solo procesar si el cambio es para el jugador local
	if targetPlayer ~= player then
		-- El cambio es para otro jugador, OtherPlayersCarSuit lo manejará
		return
	end

	-- Verificar si ya tiene este EquipType equipado (usando caché local)
	if currentEquipTypeCache == newEquipType then
		print("[ChangeCarModel] Ya tienes equipado EquipType " .. newEquipType)
		return
	end

	print("[ChangeCarModel] Cambiando de EquipType " .. currentEquipTypeCache .. " → " .. newEquipType)

	-- ═══════════════════════════════════════════════════════════════════
	-- DECISIÓN: ¿Requiere cambio de modelo o solo texturas?
	-- ═══════════════════════════════════════════════════════════════════
	local requiresReload = CarCustomizationUtils.RequiresModelChange(
		currentEquipTypeCache,
		newEquipType,
		CarConfigs
	)

	if requiresReload then
		-- ═══════════════════════════════════════════════════════════════
		-- CASO 1: CAMBIO DE MODELO COMPLETO (con reload)
		-- ═══════════════════════════════════════════════════════════════
		print("[ChangeCarModel] ⟳ Requiere recarga de modelo")

		-- Guardar posición actual antes de recargar
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			_G.RespawnPosition = humanoidRootPart.Position
		end

		-- Guardar el nuevo EquipType para que CarSuit lo use al respawnear
		_G.CurrentCarEquipType = newEquipType

		-- Actualizar caché local
		currentEquipTypeCache = newEquipType

		-- Recargar personaje para aplicar el nuevo modelo
		player:LoadCharacter()
	else
		-- ═══════════════════════════════════════════════════════════════
		-- CASO 2: SOLO CAMBIO DE TEXTURAS (instantáneo)
		-- ═══════════════════════════════════════════════════════════════
		print("[ChangeCarModel] ✨ Cambio instantáneo de texturas")

		-- Verificar que la función exportada por CarSuit existe
		if not _G.ChangeCarTextures then
			warn("[ChangeCarModel] ⚠ _G.ChangeCarTextures no disponible, recargando personaje")
			-- Fallback: si por alguna razón la función no está disponible, recargar
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				_G.RespawnPosition = humanoidRootPart.Position
			end
			_G.CurrentCarEquipType = newEquipType
			currentEquipTypeCache = newEquipType
			player:LoadCharacter()
			return
		end

		-- Aplicar texturas dinámicamente SIN recargar
		local success = _G.ChangeCarTextures(newEquipType)

		if success then
			-- Actualizar caché local
			currentEquipTypeCache = newEquipType
			print("[ChangeCarModel] ✓ Texturas cambiadas exitosamente")
		else
			warn("[ChangeCarModel] ⚠ Error cambiando texturas, recargando personaje")
			-- Fallback: si falla la aplicación de texturas, recargar
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				_G.RespawnPosition = humanoidRootPart.Position
			end
			_G.CurrentCarEquipType = newEquipType
			currentEquipTypeCache = newEquipType
			player:LoadCharacter()
		end
	end
end)

print("[ChangeCarModel] ✅ Sistema híbrido inicializado")
