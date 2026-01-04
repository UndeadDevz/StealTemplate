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

-- Esperar elementos de UI con timeout
local rebirthModal = playerGui:WaitForChild("RebirthModal", 10)
if not rebirthModal then
	warn("[RebirthProgressBar] No se encontró RebirthModal")
	return
end

local fovRebirthModal = rebirthModal:WaitForChild("Fov_RebirthModal", 5)
if not fovRebirthModal then
	warn("[RebirthProgressBar] No se encontró Fov_RebirthModal")
	return
end

local progressBarToRebirth = fovRebirthModal:WaitForChild("ProgressBarToRebirth", 5)
if not progressBarToRebirth then
	warn("[RebirthProgressBar] No se encontró ProgressBarToRebirth")
	return
end

local bar = progressBarToRebirth:WaitForChild("bar", 5)
local text = progressBarToRebirth:WaitForChild("Text", 5)

if not bar or not text then
	warn("[RebirthProgressBar] No se encontró bar o Text dentro de ProgressBarToRebirth")
	return
end

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Calcula el nivel requerido para el siguiente rebirth
-- FÓRMULA: 25 + (rebirths * 25) - sincronizada con RebirthSystem.server.luau
local function getLevelRequired(rebirths)
	return 25 + (rebirths * 25)
end

local function updateLevelBar(currentLevel, rebirths)
	local levelRequired = getLevelRequired(rebirths)
	local ratio = math.clamp(currentLevel / levelRequired, 0, 1)
	local targetSize = UDim2.fromScale(ratio, 1)

	TweenService:Create(bar, tweenInfo, {Size = targetSize}):Play()

	if currentLevel >= levelRequired then
		text.Text = "¡LISTO PARA REBIRTH!"
	else
		text.Text = currentLevel .. " / " .. levelRequired
	end
end

-- Esperar a que carguen los leaderstats
local leaderstats = player:WaitForChild("leaderstats", 10)
if not leaderstats then
	warn("[RebirthProgressBar] No se encontraron leaderstats")
	return
end

local currentLevel = leaderstats:WaitForChild("Level", 5)
local currentRebirths = leaderstats:WaitForChild("Rebirths", 5)

if not currentLevel or not currentRebirths then
	warn("[RebirthProgressBar] No se encontró Level o Rebirths en leaderstats")
	return
end

-- Escuchar cambios
local function onStatsChanged()
	updateLevelBar(currentLevel.Value, currentRebirths.Value)
end

currentLevel.Changed:Connect(onStatsChanged)
currentRebirths.Changed:Connect(onStatsChanged)

-- Inicializar
updateLevelBar(currentLevel.Value, currentRebirths.Value)

print("✅ RebirthProgressBarUpdater inicializado")
