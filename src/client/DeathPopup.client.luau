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

local function showButton(checkpointData)
	print("✅ Mostrando botón")
	checkpointButton.Visible = true

	task.delay(6, function()
		print("⏰ Ocultando botón después de 6 segundos")
		checkpointButton.Visible = false
	end)
end



-- ═══════════════════════════════════════════════════════════════════════
-- CLICK HANDLER DEL BOTÓN
-- ═══════════════════════════════════════════════════════════════════════

checkpointButton.MouseButton1Click:Connect(function()
	print("🖱️ Click en botón")
	MarketplaceService:PromptProductPurchase(player, CHECKPOINT_PRODUCT_ID)
	checkpointButton.Visible = false
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
	print("✅ Compra exitosa, teleportando")
	teleportToCheckpointEvent:FireServer()
	checkpointButton.Visible = false
end)

print("[CheckpointButton] ✅ Sistema inicializado")
