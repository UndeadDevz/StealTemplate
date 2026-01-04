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

-- Obtiene el ratio de crecimiento según el nivel
local function getRatioForLevel(level: number): number
	if level <= 25 then return 1.05
	elseif level <= 50 then return 1.10
	elseif level <= 125 then return 1.15
	elseif level <= 175 then return 1.20
	elseif level <= 275 then return 1.25
	else return 1.30  -- 276+
	end
end

-- Calcula la EXP necesaria para subir de nivel (Exponencial)
local function getRequiredExp(level)
	local ratio = getRatioForLevel(level)
	return math.floor(51 * (ratio ^ level))
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