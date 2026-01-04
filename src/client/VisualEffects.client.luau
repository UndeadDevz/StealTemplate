local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar RemoteFunction
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local getStat = remoteEvents:WaitForChild("GetStat")


-- Crear una GUI contenedora si no existe
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EffectsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ID de la imagen de alas (puedes cambiar este número por tu propia imagen)
-- Este es un icono de alas genérico de Roblox
local WINGS_ICON_ID = "rbxassetid://130057163043800" -- O prueba 13418296060

local function SpawnWings()
	-- 1. Crear la imagen
	print('🕊️ SpawnWings activado')
	local icon = Instance.new("ImageLabel")
	icon.Name = "ExpWings"
	icon.Image = WINGS_ICON_ID
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.new(0, 100, 0, 100) -- Tamaño de las alas
	icon.AnchorPoint = Vector2.new(0.5, 0.5) -- Centro exacto
	icon.Position = UDim2.new(0.5, 0, 0.5, 0) -- Centro de la pantalla
	icon.ZIndex = 10
	icon.Parent = screenGui

	-- 2. Calcular dirección aleatoria
	local randomX = math.random(-200, 200)
	local randomY = math.random(-200, 200) -- Puede ir arriba o abajo

	-- Posición final a donde volarán
	local endPos = UDim2.new(0.5, randomX, 0.5, randomY)

	-- 3. Animación (Mover + Desvanecer + Crecer un poco)
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local goal = {
		Position = endPos,
		ImageTransparency = 1, -- Desaparece
		Size = UDim2.new(0, 150, 0, 150), -- Crece un poco al salir
	}

	local tween = TweenService:Create(icon, tweenInfo, goal)
	tween:Play()

	-- 4. Limpieza automática
	tween.Completed:Connect(function()
		icon:Destroy()
	end)
end

-- Monitorear cambios de EXP cada 0.5 segundos
local lastExp = 0
task.spawn(function()
	while task.wait(0.5) do
		local currentExp = getStat:InvokeServer("EXP")
		if currentExp and currentExp > lastExp then
			SpawnWings()
			lastExp = currentExp
		elseif currentExp then
			lastExp = currentExp
		end
	end
end)
