local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- 1. IMPORTAR TU FORMATTER
-- Usamos la misma ruta que en tu script de cliente: ReplicatedStorage > Utils > NumberFormatter
local NumberFormatter = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("NumberFormatter"))

-- Detectar entorno: Test (Studio) o Live (Producción)
local isTestEnvironment = RunService:IsStudio()
local dataStorePrefix = isTestEnvironment and "Test_" or ""

local WinsODS = DataStoreService:GetOrderedDataStore(dataStorePrefix .. "GlobalWins_v1")
local SpeedODS = DataStoreService:GetOrderedDataStore(dataStorePrefix .. "GlobalSpeed_v1")

local UPDATE_TIME = 60
local MAX_ITEMS = 10

-- Referencias a las Parts (asegúrate de que los nombres coincidan con tu Workspace)
local WinsBoardPart = workspace:WaitForChild("WinsLeaderboard"):WaitForChild("Board")
local SpeedBoardPart = workspace:WaitForChild("SpeedLeaderboard"):WaitForChild("Board")

local function UpdateBoard(ods, boardPart, statName)
	local success, pages = pcall(function()
		return ods:GetSortedAsync(false, MAX_ITEMS)
	end)

	if not success then return end

	local items = pages:GetCurrentPage()
	local container = boardPart.SurfaceGui.Container

	-- Limpiar lista anterior
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for rank, data in ipairs(items) do
		local userId = data.key
		local value = data.value
		local playerName = "[Cargando...]"

		local s, name = pcall(function()
			return Players:GetNameFromUserIdAsync(userId)
		end)
		if s then playerName = name end

		-- 2. APLICAR EL FORMATO
		-- Usamos .Format() para sufijos (1.5k) o .FormatWithCommas() para comas (1,500)
		-- Según tu archivo NumberFormatter[cite: 9], .Format es ideal para leaderboards
		local displayValue = NumberFormatter.Format(value) 

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0.1, 0) -- 10% de altura por fila (para 10 items)
		row.BackgroundTransparency = 1
		row.LayoutOrder = rank
		row.Parent = container

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextScaled = true -- Ajusta el texto automáticamente
		textLabel.Font = Enum.Font.FredokaOne -- Fuente recomendada tipo "Cartoon"

		-- Formato final: "#1 Nombre: 1.5k"
		textLabel.Text = string.format("#%d %s: %s", rank, playerName, displayValue)
		textLabel.Parent = row
	end
end

while true do
	task.spawn(function() UpdateBoard(WinsODS, WinsBoardPart, "Wins") end)
	task.spawn(function() UpdateBoard(SpeedODS, SpeedBoardPart, "Speed") end)
	task.wait(UPDATE_TIME)
end