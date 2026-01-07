local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local expGainedEvent = remoteEvents:WaitForChild("ExpGainedEvent")


-- Crear una GUI contenedora si no existe
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EffectsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ID de la imagen de alas (puedes cambiar este número por tu propia imagen)
-- Este es un icono de alas genérico de Roblox
local WINGS_ICON_ID = "rbxassetid://130057163043800" -- O prueba 13418296060

local function SpawnWings(expAmount)
	-- 1. Crear la imagen
	local icon = Instance.new("ImageLabel")
	icon.Name = "ExpWings"
	icon.Image = WINGS_ICON_ID
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.new(0, 70, 0, 70) -- Tamaño inicial (30% más pequeño: 100 -> 70)
	icon.AnchorPoint = Vector2.new(0.5, 0.5) -- Centro exacto
	
	-- Punto de origen aleatorio en un área central de la pantalla
	local originX = math.random(-150, 150)
	local originY = math.random(-120, 120)
	icon.Position = UDim2.new(0.5, originX, 0.5, originY)
	
	icon.ZIndex = 10
	icon.Parent = screenGui

	-- 1.5. Crear el texto de EXP pegado a la imagen
	local expText = Instance.new("TextLabel")
	expText.Name = "ExpText"
	expText.Text = "+" .. string.format("%.1f", expAmount)
	expText.Font = Enum.Font.GothamBold
	expText.TextSize = 18
	expText.TextColor3 = Color3.fromRGB(255, 215, 0) -- Dorado
	expText.TextStrokeTransparency = 0.5
	expText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	expText.BackgroundTransparency = 1
	expText.Size = UDim2.new(1, 0, 0.3, 0) -- Ancho completo de la imagen, altura proporcional
	expText.Position = UDim2.new(0, 0, 0.7, 0) -- Pegado abajo de la imagen
	expText.ZIndex = 11
	expText.Parent = icon

	-- 2. Calcular dirección HACIA AFUERA desde el punto de origen
	-- Si originX es positivo, va más a la derecha. Si es negativo, va más a la izquierda.
	local directionX = originX >= 0 and 1 or -1
	local directionY = originY >= 0 and 1 or -1
	
	-- Distancia aleatoria hacia afuera (siempre positiva, la dirección la define el signo)
	local distanceX = math.random(200, 400)
	local distanceY = math.random(160, 320)
	
	local randomX = originX + (distanceX * directionX)
	local randomY = originY + (distanceY * directionY)

	-- Posición final a donde volarán (siempre hacia afuera del centro)
	local endPos = UDim2.new(0.5, randomX, 0.5, randomY)

	-- 3. Animación (Mover + Desvanecer + Crecer un poco)
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local goalIcon = {
		Position = endPos,
		ImageTransparency = 1, -- Desaparece
		Size = UDim2.new(0, 105, 0, 105), -- Crece un poco al salir (30% más pequeño: 150 -> 105)
	}

	local goalText = {
		TextTransparency = 1, -- Desaparece
		TextStrokeTransparency = 1,
	}

	local tweenIcon = TweenService:Create(icon, tweenInfo, goalIcon)
	local tweenText = TweenService:Create(expText, tweenInfo, goalText)
	tweenIcon:Play()
	tweenText:Play()

	-- 4. Limpieza automática
	tweenIcon.Completed:Connect(function()
		icon:Destroy()
	end)
end

-- Escuchar evento del servidor cuando se gana EXP
expGainedEvent.OnClientEvent:Connect(function(expAmount)
	SpawnWings(expAmount)
end)
