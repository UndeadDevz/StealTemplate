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
local CarConfigs = require(ReplicatedStorage.Shared.CarConfigs)
local CarCustomizationUtils = require(ReplicatedStorage.Shared.CarCustomizationUtils)

local player = Players.LocalPlayer
local character = script.Parent

-- Esperar al RemoteEvent
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local changeCarModel = remoteEvents:WaitForChild("ChangeCarModel")

-- ═══════════════════════════════════════════════════════════════════════
-- OBTENER EQUIPTYPE ACTUAL
-- ═══════════════════════════════════════════════════════════════════════
local function getCurrentEquipType()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local equipTypeStat = leaderstats:FindFirstChild("EquipType")
		if equipTypeStat then
			return equipTypeStat.Value
		end
	end
	return 1 -- Default
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

	local currentEquipType = getCurrentEquipType()

	-- Verificar si ya tiene este EquipType equipado
	if currentEquipType == newEquipType then
		print("[ChangeCarModel] Ya tienes equipado EquipType " .. newEquipType)
		return
	end

	print("[ChangeCarModel] Cambiando de EquipType " .. currentEquipType .. " → " .. newEquipType)

	-- ═══════════════════════════════════════════════════════════════════
	-- DECISIÓN: ¿Requiere cambio de modelo o solo texturas?
	-- ═══════════════════════════════════════════════════════════════════
	local requiresReload = CarCustomizationUtils.RequiresModelChange(
		currentEquipType,
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
			player:LoadCharacter()
			return
		end

		-- Aplicar texturas dinámicamente SIN recargar
		local success = _G.ChangeCarTextures(newEquipType)

		if success then
			print("[ChangeCarModel] ✓ Texturas cambiadas exitosamente")
		else
			warn("[ChangeCarModel] ⚠ Error cambiando texturas, recargando personaje")
			-- Fallback: si falla la aplicación de texturas, recargar
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				_G.RespawnPosition = humanoidRootPart.Position
			end
			_G.CurrentCarEquipType = newEquipType
			player:LoadCharacter()
		end
	end
end)

print("[ChangeCarModel] ✅ Sistema híbrido inicializado")
