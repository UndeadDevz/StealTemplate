--[[
	═══════════════════════════════════════════════════════════════════════
	DEATH POPUP UI
	═══════════════════════════════════════════════════════════════════════

	Popup Dark-Tech que aparece cuando el jugador muere y tiene un checkpoint guardado.
	Ofrece teleportarse al checkpoint por 10 Robux o simplemente cerrar el popup.

	Auto-cierra después de 10 segundos.

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ═══════════════════════════════════════════════════════════════════════
local CHECKPOINT_PRODUCT_ID = 3502953308 -- ⚠️ REEMPLAZAR CON PRODUCT ID REAL DESPUÉS DE CREARLO
local POPUP_DURATION = 10 -- Segundos antes de auto-cerrar

-- Colores Dark-Tech (igual que SettingsUi)
local BLACK = Color3.fromRGB(0, 0, 0)
local BG = Color3.fromRGB(10, 10, 14)
local CARD = Color3.fromRGB(18, 18, 26)
local TEXT = Color3.fromRGB(245, 245, 245)
local MUTED = Color3.fromRGB(170, 175, 190)
local ACCENT = Color3.fromRGB(80, 220, 255) -- Cyan
local BAD = Color3.fromRGB(255, 120, 120) -- Rojo

-- ═══════════════════════════════════════════════════════════════════════
-- CREAR UI
-- ═══════════════════════════════════════════════════════════════════════

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "DeathPopupGui"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.Enabled = true
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Dim overlay (fondo oscuro semitransparente)
local dim = Instance.new("Frame")
dim.Name = "Dim"
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = BLACK
dim.BackgroundTransparency = 1
dim.Visible = false
dim.ZIndex = 1
dim.Parent = gui

-- Panel principal
local panel = Instance.new("Frame")
panel.Name = "DeathPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0, 500, 0, 300)
panel.BackgroundColor3 = BG
panel.BackgroundTransparency = 1
panel.Visible = false
panel.ZIndex = 2
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 22)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Thickness = 3
panelStroke.Color = BLACK
panelStroke.Parent = panel

-- Header: "YOU DIED"
local header = Instance.new("TextLabel")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundTransparency = 1
header.Font = Enum.Font.GothamBlack
header.TextSize = 36
header.TextColor3 = BAD
header.Text = "💀 YOU DIED"
header.ZIndex = 3
header.Parent = panel

local headerStroke = Instance.new("UIStroke")
headerStroke.Thickness = 2
headerStroke.Color = BLACK
headerStroke.Parent = header

-- Subheader: Checkpoint name
local subheader = Instance.new("TextLabel")
subheader.Name = "Subheader"
subheader.Size = UDim2.new(1, -40, 0, 30)
subheader.Position = UDim2.new(0, 20, 0, 70)
subheader.BackgroundTransparency = 1
subheader.Font = Enum.Font.GothamBold
subheader.TextSize = 16
subheader.TextColor3 = MUTED
subheader.Text = "Last checkpoint: ???"
subheader.TextXAlignment = Enum.TextXAlignment.Left
subheader.ZIndex = 3
subheader.Parent = panel

-- Botón Teleport (Cyan)
local teleportBtn = Instance.new("TextButton")
teleportBtn.Name = "TeleportBtn"
teleportBtn.Size = UDim2.new(1, -40, 0, 70)
teleportBtn.Position = UDim2.new(0, 20, 0, 110)
teleportBtn.BackgroundColor3 = ACCENT
teleportBtn.AutoButtonColor = false
teleportBtn.Font = Enum.Font.GothamBlack
teleportBtn.TextSize = 20
teleportBtn.TextColor3 = TEXT
teleportBtn.Text = "Teleport to Checkpoint\n💎 10 Robux"
teleportBtn.ZIndex = 3
teleportBtn.Parent = panel

local teleportCorner = Instance.new("UICorner")
teleportCorner.CornerRadius = UDim.new(0, 14)
teleportCorner.Parent = teleportBtn

local teleportStroke = Instance.new("UIStroke")
teleportStroke.Thickness = 2
teleportStroke.Color = BLACK
teleportStroke.Parent = teleportBtn

-- Botón Cerrar (Dark)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(1, -40, 0, 50)
closeBtn.Position = UDim2.new(0, 20, 0, 200)
closeBtn.BackgroundColor3 = CARD
closeBtn.AutoButtonColor = false
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 18
closeBtn.TextColor3 = TEXT
closeBtn.Text = "Close"
closeBtn.ZIndex = 3
closeBtn.Parent = panel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 14)
closeCorner.Parent = closeBtn

local closeStroke = Instance.new("UIStroke")
closeStroke.Thickness = 2
closeStroke.Color = BLACK
closeStroke.Parent = closeBtn

-- Contador visual (opcional)
local counterLabel = Instance.new("TextLabel")
counterLabel.Name = "CounterLabel"
counterLabel.Size = UDim2.new(1, 0, 0, 20)
counterLabel.Position = UDim2.new(0, 0, 1, -30)
counterLabel.BackgroundTransparency = 1
counterLabel.Font = Enum.Font.Gotham
counterLabel.TextSize = 14
counterLabel.TextColor3 = MUTED
counterLabel.Text = "Closes in 10s"
counterLabel.ZIndex = 3
counterLabel.Parent = panel

-- ═══════════════════════════════════════════════════════════════════════
-- LÓGICA DEL POPUP
-- ═══════════════════════════════════════════════════════════════════════

local popupVisible = false
local autoCloseCoroutine = nil

-- Abrir popup
local function openPopup(checkpointData)
	if popupVisible then
		-- Ya hay un popup visible, cerrarlo primero
		closePopup()
	end

	popupVisible = true
	dim.Visible = true
	panel.Visible = true

	-- Actualizar nombre del checkpoint
	subheader.Text = "Last checkpoint: " .. checkpointData.CheckpointName

	-- Animación de entrada
	dim.BackgroundTransparency = 1
	TweenService:Create(dim, TweenInfo.new(0.16), {BackgroundTransparency = 0.6}):Play()

	panel.Size = UDim2.new(0, 450, 0, 270)
	panel.BackgroundTransparency = 1
	TweenService:Create(panel, TweenInfo.new(0.28, Enum.EasingStyle.Quint), {
		Size = UDim2.new(0, 500, 0, 300),
		BackgroundTransparency = 0
	}):Play()

	-- Iniciar contador de auto-cierre
	if autoCloseCoroutine then
		task.cancel(autoCloseCoroutine)
	end

	autoCloseCoroutine = task.spawn(function()
		for i = POPUP_DURATION, 1, -1 do
			if not popupVisible then break end
			counterLabel.Text = string.format("Closes in %ds", i)
			task.wait(1)
		end

		if popupVisible then
			closePopup()
		end
	end)
end

-- Cerrar popup
function closePopup()
	if not popupVisible then return end

	popupVisible = false

	-- Cancelar auto-cierre si está corriendo
	if autoCloseCoroutine then
		task.cancel(autoCloseCoroutine)
		autoCloseCoroutine = nil
	end

	-- Animación de salida
	TweenService:Create(panel, TweenInfo.new(0.2), {
		BackgroundTransparency = 1
	}):Play()

	TweenService:Create(dim, TweenInfo.new(0.14), {
		BackgroundTransparency = 1
	}):Play()

	task.delay(0.22, function()
		panel.Visible = false
		dim.Visible = false
	end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- EFECTOS DE BOTONES (Hover/Click animations)
-- ═══════════════════════════════════════════════════════════════════════
local function applyButtonFX(btn)
	local origSize = btn.Size

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			Size = UDim2.new(origSize.X.Scale, origSize.X.Offset * 1.03,
			                 origSize.Y.Scale, origSize.Y.Offset * 1.05)
		}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {Size = origSize}):Play()
	end)

	btn.MouseButton1Down:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.08), {
			Size = UDim2.new(origSize.X.Scale, origSize.X.Offset * 0.97,
			                 origSize.Y.Scale, origSize.Y.Offset * 0.95)
		}):Play()
	end)

	btn.MouseButton1Up:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.08), {Size = origSize}):Play()
	end)
end

applyButtonFX(teleportBtn)
applyButtonFX(closeBtn)

-- ═══════════════════════════════════════════════════════════════════════
-- CLICK HANDLERS
-- ═══════════════════════════════════════════════════════════════════════

-- Botón Teleport
teleportBtn.MouseButton1Click:Connect(function()
	if CHECKPOINT_PRODUCT_ID == 0 then
		warn("❌ CHECKPOINT_PRODUCT_ID no configurado en DeathPopup.client.luau")
		closePopup()
		return
	end

	-- Abrir prompt de compra de Robux
	local success, err = pcall(function()
		MarketplaceService:PromptProductPurchase(player, CHECKPOINT_PRODUCT_ID)
	end)

	if not success then
		warn("❌ Error al abrir prompt de compra:", err)
	end

	-- Cerrar popup (el teleport ocurrirá después de la compra)
	closePopup()
end)

-- Botón Cerrar
closeBtn.MouseButton1Click:Connect(function()
	closePopup()
end)

-- ═══════════════════════════════════════════════════════════════════════
-- ESCUCHAR EVENTOS DEL SERVIDOR
-- ═══════════════════════════════════════════════════════════════════════

-- Esperar RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local showDeathPopupEvent = remoteEvents:WaitForChild("ShowDeathPopup")
local teleportToCheckpointEvent = remoteEvents:WaitForChild("TeleportToCheckpoint")

-- Evento: Mostrar popup
showDeathPopupEvent.OnClientEvent:Connect(function(checkpointData)
	print("🔔 Mostrar popup de muerte. Checkpoint:", checkpointData.CheckpointName)
	openPopup(checkpointData)
end)

-- Evento: Teleport activado (después de compra exitosa)
teleportToCheckpointEvent.OnClientEvent:Connect(function()
	print("✅ Compra exitosa, teleportando...")
	-- Comunicar al servidor para ejecutar el teleport
	teleportToCheckpointEvent:FireServer()
end)

print("[DeathPopup] ✅ Cliente inicializado")
