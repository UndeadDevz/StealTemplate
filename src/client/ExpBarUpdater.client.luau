local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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

-- Función de formateo (1500 -> 1.5k)
local function formatNumber(n)
	if n < 1000 then return tostring(math.floor(n)) end
	local suffixes = {"", "k", "M", "B", "T"}
	local index = 1
	while n >= 1000 and index < #suffixes do
		n = n / 1000
		index = index + 1
	end
	return string.format("%.1f%s", n, suffixes[index]):gsub("%.0", "")
end

-- Calcula la EXP necesaria para subir de nivel
local function getRequiredExp(level)
	return level * 100
end

-- Calcula el nivel máximo según los rebirths
local function getMaxLevel(rebirths)
	return 20 + (rebirths * 10)
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
		text.Text = formatNumber(maxExp) .. " / " .. formatNumber(maxExp)

		-- Nivel MAX
		levelText.Text = "MAX"
	else
		-- Comportamiento normal
		local ratio = math.clamp(currentExp / maxExp, 0, 1)
		local targetSize = UDim2.fromScale(ratio, 1)
		TweenService:Create(bar, tweenInfo, {Size = targetSize}):Play()

		text.Text = formatNumber(currentExp) .. " / " .. formatNumber(maxExp)
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