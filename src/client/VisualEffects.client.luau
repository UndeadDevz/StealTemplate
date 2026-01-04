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
	icon.Size = UDim2.new(0, 70, 0, 70) -- Tamaño inicial (30% más pequeño: 100 -> 70)
	icon.AnchorPoint = Vector2.new(0.5, 0.5) -- Centro exacto
	
	-- Punto de origen aleatorio en un área central de la pantalla
	local originX = math.random(-150, 150)
	local originY = math.random(-120, 120)
	icon.Position = UDim2.new(0.5, originX, 0.5, originY)
	
	icon.ZIndex = 10
	icon.Parent = screenGui

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

	local goal = {
		Position = endPos,
		ImageTransparency = 1, -- Desaparece
		Size = UDim2.new(0, 105, 0, 105), -- Crece un poco al salir (30% más pequeño: 150 -> 105)
	}

	local tween = TweenService:Create(icon, tweenInfo, goal)
	tween:Play()

	-- 4. Limpieza automática
	tween.Completed:Connect(function()
		icon:Destroy()
	end)
end

-- Monitorear cambios de EXP cada 0.1 segundos (10 veces por segundo)
local lastExp = 0
task.spawn(function()
	while task.wait(0.1) do
		local currentExp = getStat:InvokeServer("EXP")
		if currentExp and currentExp > lastExp then
			SpawnWings()
			lastExp = currentExp
		elseif currentExp then
			lastExp = currentExp
		end
	end
end)
