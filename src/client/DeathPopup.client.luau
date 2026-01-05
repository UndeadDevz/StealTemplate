--[[
	═══════════════════════════════════════════════════════════════════════
	CHECKPOINT BUTTON HANDLER
	═══════════════════════════════════════════════════════════════════════

	Usa el botón existente en StarterGui/Buttons/ScreenGui/CheckpointButton.
	Aparece cuando el jugador muere y tiene un checkpoint guardado.
	Ofrece teleportarse al checkpoint por 10 Robux.

	Auto-oculta después de 6 segundos.

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════════════════
local CHECKPOINT_PRODUCT_ID = 3502953308
local BUTTON_DURATION = 6 -- Segundos antes de auto-ocultar

-- ═══════════════════════════════════════════════════════════════════════
-- BUSCAR BOTÓN EXISTENTE
-- ═══════════════════════════════════════════════════════════════════════

-- Buscar el botón en StarterGui/Buttons/ScreenGui/CheckpointButton
local buttonsGui = playerGui:WaitForChild("Buttons", 10)
if not buttonsGui then
	warn("❌ [CheckpointButton] No se encontró ScreenGui 'Buttons'")
	return
end

local checkpointButton = buttonsGui:WaitForChild("CheckpointButton", 10)
if not checkpointButton then
	warn("❌ [CheckpointButton] No se encontró 'CheckpointButton' en Buttons ScreenGui")
	return
end

-- Ocultar el botón inicialmente
checkpointButton.Visible = false

print("✅ [CheckpointButton] Botón encontrado y configurado")

-- ═══════════════════════════════════════════════════════════════════════
-- LÓGICA DEL BOTÓN
-- ═══════════════════════════════════════════════════════════════════════

local buttonVisible = false
local autoHideCoroutine = nil

-- Ocultar botón
local function hideButton()
	if not buttonVisible then return end

	buttonVisible = false
	checkpointButton.Visible = false

	-- Cancelar auto-hide si está corriendo
	if autoHideCoroutine then
		task.cancel(autoHideCoroutine)
		autoHideCoroutine = nil
	end

	print("🔒 [CheckpointButton] Botón ocultado")
end
-- Mostrar botón
local function showButton(checkpointData)
	if buttonVisible then
		-- Ya hay un botón visible, ocultarlo primero
		hideButton()
	end

	buttonVisible = true
	checkpointButton.Visible = true

	print("✅ [CheckpointButton] Botón mostrado para checkpoint:", checkpointData.CheckpointName)

	-- Iniciar timer de auto-ocultar (6 segundos)
	if autoHideCoroutine then
		task.cancel(autoHideCoroutine)
	end

	autoHideCoroutine = task.spawn(function()
		task.wait(BUTTON_DURATION)
		if buttonVisible then
			hideButton()
		end
	end)
end



-- ═══════════════════════════════════════════════════════════════════════
-- CLICK HANDLER DEL BOTÓN
-- ═══════════════════════════════════════════════════════════════════════

checkpointButton.MouseButton1Click:Connect(function()
	print("🖱️ [CheckpointButton] Click detectado")

	-- Abrir prompt de compra de Robux
	local success, err = pcall(function()
		MarketplaceService:PromptProductPurchase(player, CHECKPOINT_PRODUCT_ID)
	end)

	if not success then
		warn("❌ Error al abrir prompt de compra:", err)
	end

	-- Ocultar botón (el teleport ocurrirá después de la compra)
	hideButton()
end)

-- ═══════════════════════════════════════════════════════════════════════
-- ESCUCHAR EVENTOS DEL SERVIDOR
-- ═══════════════════════════════════════════════════════════════════════

-- Esperar RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local showDeathPopupEvent = remoteEvents:WaitForChild("ShowDeathPopup")
local teleportToCheckpointEvent = remoteEvents:WaitForChild("TeleportToCheckpoint")

-- Evento: Mostrar botón de checkpoint
showDeathPopupEvent.OnClientEvent:Connect(function(checkpointData)
	print("🔔 [CheckpointButton] Mostrar botón. Checkpoint:", checkpointData.CheckpointName)
	showButton(checkpointData)
end)

-- Evento: Teleport activado (después de compra exitosa)
teleportToCheckpointEvent.OnClientEvent:Connect(function()
	print("✅ [CheckpointButton] Compra exitosa, teleportando...")
	-- Comunicar al servidor para ejecutar el teleport
	teleportToCheckpointEvent:FireServer()
	-- Ocultar botón
	hideButton()
end)

print("[CheckpointButton] ✅ Sistema inicializado")
