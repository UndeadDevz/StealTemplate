--[[
	═══════════════════════════════════════════════════════════════════════
	CHANGE CAR MODEL HANDLER - SISTEMA SIN RELOAD
	═══════════════════════════════════════════════════════════════════════

	Este script escucha cuando el servidor notifica un cambio de EquipType
	y decide dinámicamente si:
	- Cambiar texturas instantáneamente (sin cambio de modelo)
	- Cambiar modelo completo (destruir y recrear, sin reload de personaje)

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Importar módulos del sistema híbrido
local Shared = ReplicatedStorage:WaitForChild("Shared")
local CarConfigs = require(Shared:WaitForChild("CarConfigs"))
local CarCustomizationUtils = require(Shared:WaitForChild("CarCustomizationUtils"))

local player = Players.LocalPlayer

-- Esperar al RemoteEvent
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local changeCarModel = remoteEvents:WaitForChild("ChangeCarModel")

-- ═══════════════════════════════════════════════════════════════════════
-- CACHÉ LOCAL DEL EQUIPTYPE ACTUAL
-- ═══════════════════════════════════════════════════════════════════════
local currentEquipTypeCache = nil

-- ═══════════════════════════════════════════════════════════════════════
-- HANDLER DE CAMBIO DE EQUIPTYPE
-- ═══════════════════════════════════════════════════════════════════════
changeCarModel.OnClientEvent:Connect(function(targetPlayer, newEquipType)
	-- Solo procesar si el cambio es para el jugador local
	if targetPlayer ~= player then
		return
	end

	-- Si es la primera vez, inicializar el caché
	if currentEquipTypeCache == nil then
		currentEquipTypeCache = newEquipType
		print("[ChangeCarModel] EquipType inicial del servidor: " .. newEquipType)
		return
	end

	-- Verificar si ya tiene este EquipType equipado
	if currentEquipTypeCache == newEquipType then
		print("[ChangeCarModel] Ya tienes equipado EquipType " .. newEquipType)
		return
	end

	print("[ChangeCarModel] Cambiando de EquipType " .. currentEquipTypeCache .. " → " .. newEquipType)

	-- ═══════════════════════════════════════════════════════════════════
	-- DECISIÓN: ¿Requiere cambio de modelo o solo texturas?
	-- ═══════════════════════════════════════════════════════════════════
	local requiresModelChange = CarCustomizationUtils.RequiresModelChange(
		currentEquipTypeCache,
		newEquipType,
		CarConfigs
	)

	if requiresModelChange then
		-- ═══════════════════════════════════════════════════════════════
		-- CASO 1: CAMBIO DE MODELO COMPLETO (sin reload)
		-- ═══════════════════════════════════════════════════════════════
		print("[ChangeCarModel] ⟳ Requiere cambio de modelo")

		-- Esperar a que _G.ChangeCarModel esté disponible
		local attempts = 0
		while not _G.ChangeCarModel and attempts < 50 do
			task.wait(0.1)
			attempts = attempts + 1
		end

		if not _G.ChangeCarModel then
			warn("[ChangeCarModel] ⚠ _G.ChangeCarModel no disponible")
			return
		end

		local success = _G.ChangeCarModel(newEquipType)

		if success then
			currentEquipTypeCache = newEquipType
			print("[ChangeCarModel] ✓ Modelo cambiado exitosamente")
		else
			warn("[ChangeCarModel] ⚠ Error cambiando modelo")
		end
	else
		-- ═══════════════════════════════════════════════════════════════
		-- CASO 2: SOLO CAMBIO DE TEXTURAS (instantáneo)
		-- ═══════════════════════════════════════════════════════════════
		print("[ChangeCarModel] ✨ Cambio instantáneo de texturas")

		-- Esperar a que _G.ChangeCarTextures esté disponible
		local attempts = 0
		while not _G.ChangeCarTextures and attempts < 50 do
			task.wait(0.1)
			attempts = attempts + 1
		end

		if not _G.ChangeCarTextures then
			warn("[ChangeCarModel] ⚠ _G.ChangeCarTextures no disponible")
			-- Fallback: intentar con cambio de modelo completo
			if _G.ChangeCarModel then
				local success = _G.ChangeCarModel(newEquipType)
				if success then
					currentEquipTypeCache = newEquipType
				end
			end
			return
		end

		local success = _G.ChangeCarTextures(newEquipType)

		if success then
			currentEquipTypeCache = newEquipType
			print("[ChangeCarModel] ✓ Texturas cambiadas exitosamente")
		else
			warn("[ChangeCarModel] ⚠ Error cambiando texturas, intentando cambio de modelo")
			-- Fallback: si falla texturas, intentar cambio completo
			if _G.ChangeCarModel then
				local modelSuccess = _G.ChangeCarModel(newEquipType)
				if modelSuccess then
					currentEquipTypeCache = newEquipType
				end
			end
		end
	end
end)

print("[ChangeCarModel] ✅ Sistema de cambio dinámico inicializado (sin reload)")
