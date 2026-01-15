--[[
	═══════════════════════════════════════════════════════════════════════
	REBIRTH PROGRESS BAR UPDATER
	═══════════════════════════════════════════════════════════════════════
	
	Actualiza la barra de progreso hacia el siguiente rebirth.
	Ubicación: RebirthModal > Fov_RebirthModal > ProgressBarToRebirth
	
	FÓRMULA DE NIVEL REQUERIDO (sincronizada con RebirthSystem.server.luau):
	- Rebirth 0 → Requiere Nivel 25
	- Rebirth 1 → Requiere Nivel 50
	- Rebirth 2 → Requiere Nivel 75
	- nivelRequerido = 25 + (rebirths * 25)
	
	═══════════════════════════════════════════════════════════════════════
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Referencias a la Notificación (en la ScreenGui Buttons)
local buttonsGui = playerGui:WaitForChild("Buttons", 10)
local lookHereRebirth = buttonsGui and buttonsGui:FindFirstChild("LookHereRebirth", true)

-- 2. Esperar elementos de UI de la Barra de Progreso
local rebirthModal = playerGui:WaitForChild("RebirthModal", 10)
local fovRebirthModal = rebirthModal and rebirthModal:WaitForChild("Fov_RebirthModal", 5)
local progressBarToRebirth = fovRebirthModal and fovRebirthModal:WaitForChild("ProgressBarToRebirth", 5)

if not progressBarToRebirth then
    warn("[RebirthProgressBar] No se encontró la jerarquía de UI del Rebirth")
    return
end

local bar = progressBarToRebirth:WaitForChild("bar", 5)
local text = progressBarToRebirth:WaitForChild("Text", 5)

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- FÓRMULA: 25 + (rebirths * 25)
local function getLevelRequired(rebirths)
    return 25 + (rebirths * 25)
end

-- 3. Función para actualizar la notificación (!)
local function checkNotification(currentLevel, rebirths)
    if not lookHereRebirth then return end
    
    local levelRequired = getLevelRequired(rebirths)
    
    -- Si el nivel es suficiente, mostrar el signo de exclamación
    if currentLevel >= levelRequired then
        lookHereRebirth.Visible = true
    else
        lookHereRebirth.Visible = false
    end
end

local function updateLevelBar(currentLevel, rebirths)
    local levelRequired = getLevelRequired(rebirths)
    local ratio = math.clamp(currentLevel / levelRequired, 0, 1)
    local targetSize = UDim2.fromScale(ratio, 1)

    -- Actualizar barra con Tween
    TweenService:Create(bar, tweenInfo, {Size = targetSize}):Play()

    -- Actualizar texto de la barra
    if currentLevel >= levelRequired then
        text.Text = "¡LISTO PARA REBIRTH!"
    else
        text.Text = currentLevel .. " / " .. levelRequired
    end
    
    -- Actualizar visibilidad del signo "!"
    checkNotification(currentLevel, rebirths)
end

-- 4. Esperar a que carguen los leaderstats
local leaderstats = player:WaitForChild("leaderstats", 10)
local currentLevelValue = leaderstats:WaitForChild("Level", 5)
local currentRebirthsValue = leaderstats:WaitForChild("Rebirths", 5)

if not currentLevelValue or not currentRebirthsValue then
    warn("[RebirthProgressBar] No se encontró Level o Rebirths")
    return
end

-- Escuchar cambios en los valores
local function onStatsChanged()
    updateLevelBar(currentLevelValue.Value, currentRebirthsValue.Value)
end

currentLevelValue.Changed:Connect(onStatsChanged)
currentRebirthsValue.Changed:Connect(onStatsChanged)

-- Inicializar al cargar
updateLevelBar(currentLevelValue.Value, currentRebirthsValue.Value)

print("✅ RebirthProgressBar y LookHereRebirth inicializados")