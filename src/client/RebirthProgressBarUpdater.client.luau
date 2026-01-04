--[[
	═══════════════════════════════════════════════════════════════════════
	REBIRTH PROGRESS BAR UPDATER
	═══════════════════════════════════════════════════════════════════════
	
	Actualiza la barra de progreso hacia el siguiente rebirth.
	Ubicación: RebirthModal > Fov_RebirthModal > ProgressBarToRebirth
	
	═══════════════════════════════════════════════════════════════════════
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local rebirthModal = playerGui:WaitForChild("RebirthModal")
local fovRebirthModal = rebirthModal:WaitForChild("Fov_RebirthModal")
local progressBarToRebirth = fovRebirthModal:WaitForChild("ProgressBarToRebirth")
local bar = progressBarToRebirth:WaitForChild("bar")
local text = progressBarToRebirth:WaitForChild("Text")

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Calcula el nivel máximo según los rebirths
local function getMaxLevel(rebirths)
	return 20 + (rebirths * 10)
end

local function updateLevelBar(currentLevel, rebirths)
	local maxLevel = getMaxLevel(rebirths)
	local ratio = math.clamp(currentLevel / maxLevel, 0, 1)
	local targetSize = UDim2.fromScale(ratio, 1)

	TweenService:Create(bar, tweenInfo, {Size = targetSize}):Play()

	if currentLevel >= maxLevel then
		text.Text = "MAX"
	else
		text.Text = currentLevel .. " / " .. maxLevel
	end
end

-- Esperar a que carguen los leaderstats
local leaderstats = player:WaitForChild("leaderstats")
local currentLevel = leaderstats:WaitForChild("Level")
local currentRebirths = leaderstats:WaitForChild("Rebirths")

-- Escuchar cambios
local function onStatsChanged()
	updateLevelBar(currentLevel.Value, currentRebirths.Value)
end

currentLevel.Changed:Connect(onStatsChanged)
currentRebirths.Changed:Connect(onStatsChanged)

-- Inicializar
updateLevelBar(currentLevel.Value, currentRebirths.Value)

print("✅ RebirthProgressBarUpdater inicializado")
