local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Import centralized NumberFormatter
local NumberFormatter = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("NumberFormatter"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local buttonsGui = playerGui:WaitForChild("Buttons")
local expBar = buttonsGui:WaitForChild("ExpBar")
local bar = expBar:WaitForChild("bar")
local text = expBar:WaitForChild("Text")
local levelText = expBar:WaitForChild("Level")

-- Esperar RemoteFunction
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local getStat = remoteEvents:WaitForChild("GetStat")

-- Configuración de suavizado
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Calcula la EXP necesaria para subir de nivel
-- Sistema de 3 fases: Lineal → Transición → Exponencial
local function getRequiredExp(level)
	if level <= 25 then
		-- FASE 1: Tutorial (Lineal) - Niveles 0-25
		-- Crecimiento de ~13 puntos por nivel
		return math.floor(51 + (level * 13))

	elseif level <= 50 then
		-- FASE 2A: Transición Temprana (Ratio 1.05) - Niveles 26-50
		-- Los números empiezan a multiplicarse suavemente
		return math.floor(373 * (1.05 ^ (level - 25)))

	elseif level <= 75 then
		-- FASE 2B: Transición Media (Ratio 1.10) - Niveles 51-75
		-- La curva empieza a empinarse
		return math.floor(2120 * (1.10 ^ (level - 50)))

	else
		-- FASE 3: Muro Exponencial (Ratio 1.15) - Niveles 76+
		-- Cada 5 niveles la EXP se duplica
		-- Nivel 100 = 1.17M, Nivel 105 = 2.36M
		return math.floor(35650 * (1.15 ^ (level - 75)))
	end
end

-- Calcula el nivel máximo según los rebirths (Hard cap at 375)
local function getMaxLevel(rebirths)
	local calculatedMax = 25 + (rebirths * 25)
	return math.min(calculatedMax, 375)
end

local function updateExp(currentExp, level, rebirths)
	local maxExp = getRequiredExp(level)
	local maxLevel = getMaxLevel(rebirths)

	-- Si está en nivel máximo, mostrar barra llena
	if level >= maxLevel then
		-- Barra llena
		local targetSize = UDim2.fromScale(1, 1)
		TweenService:Create(bar, tweenInfo, {Size = targetSize}):Play()

		-- Texto mostrando EXP completa
		text.Text = NumberFormatter.FormatProgress(maxExp, maxExp)

		-- Nivel MAX
		levelText.Text = "MAX"
	else
		-- Comportamiento normal
		local ratio = math.clamp(currentExp / maxExp, 0, 1)
		local targetSize = UDim2.fromScale(ratio, 1)
		TweenService:Create(bar, tweenInfo, {Size = targetSize}):Play()

		text.Text = NumberFormatter.FormatProgress(currentExp, maxExp)
		levelText.Text = tostring(level)
	end
end

-- Esperar a que carguen los leaderstats
local leaderstats = player:WaitForChild("leaderstats")
local currentLevel = leaderstats:WaitForChild("Level")
local currentRebirths = leaderstats:WaitForChild("Rebirths")

-- Función para actualizar usando GetStat
local function onStatsChanged()
	local currentExp = getStat:InvokeServer("EXP")
	updateExp(currentExp, currentLevel.Value, currentRebirths.Value)
end

currentLevel.Changed:Connect(onStatsChanged)
currentRebirths.Changed:Connect(onStatsChanged)

-- Actualizar cada 0.5 segundos (para ver el progreso de EXP en tiempo real)
task.spawn(function()
	while task.wait(0.5) do
		local currentExp = getStat:InvokeServer("EXP")
		updateExp(currentExp, currentLevel.Value, currentRebirths.Value)
	end
end)

-- Inicializar
onStatsChanged()