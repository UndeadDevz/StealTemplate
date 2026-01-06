--[[
	═══════════════════════════════════════════════════════════════════════
	INPUT DE VELOCIDAD PERSONALIZADA (CLIENTE)
	═══════════════════════════════════════════════════════════════════════
	
	Permite al jugador escribir una velocidad deseada en un TextBox.
	La validación real se hace en el servidor.
	
	Ubicación UI: StarterGui > Buttons > CustomSpeed > TextBox
	
	═══════════════════════════════════════════════════════════════════════
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuración
local BASE_SPEED = 4

-- Esperar al RemoteEvent
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local setCustomSpeedEvent = remoteEventsFolder:WaitForChild("SetCustomSpeed")

-- Referencias a la UI
local buttonsGui = playerGui:WaitForChild("Buttons")
local customSpeedFrame = buttonsGui:WaitForChild("CustomSpeed")
local textBox = customSpeedFrame:WaitForChild("TextBox")
local maxSpeedLabel = customSpeedFrame:WaitForChild("MaxSpeedValue")

-- Referencia al nivel en leaderstats (solo para mostrar el máximo, no para validar)
local leaderstats = player:WaitForChild("leaderstats")
local levelValue = leaderstats:WaitForChild("Level")

-- Función para calcular y mostrar la velocidad máxima
local function GetMaxSpeed()
	local nivel = levelValue.Value
	return BASE_SPEED + (nivel * 2)
end

local function UpdateMaxSpeedDisplay()
	maxSpeedLabel.Text = tostring(GetMaxSpeed())
end

-- Función para mostrar la velocidad actual en el TextBox
local function UpdateCurrentSpeedDisplay()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local currentSpeed = math.floor(humanoid.WalkSpeed)
	local maxSpeed = GetMaxSpeed()
	
	-- Si está al máximo, mostrar el máximo como placeholder (indica sin límite)
	if currentSpeed >= maxSpeed then
		textBox.Text = tostring(maxSpeed)
	else
		textBox.Text = tostring(currentSpeed)
	end
end

-- Actualizar al inicio
UpdateMaxSpeedDisplay()
UpdateCurrentSpeedDisplay()

-- Actualizar cuando sube de nivel
levelValue.Changed:Connect(function()
	UpdateMaxSpeedDisplay()
	
	-- Si el jugador está al máximo (sin límite), actualizar también el TextBox
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			local currentSpeed = math.floor(humanoid.WalkSpeed)
			local oldMax = currentSpeed -- La velocidad actual era el máximo anterior
			local newMax = GetMaxSpeed()
			
			-- Si estaba al máximo (o cerca), actualizar el TextBox al nuevo máximo
			if currentSpeed >= newMax - 2 then
				textBox.Text = tostring(newMax)
			end
		end
	end
end)

-- Actualizar cuando respawnea el jugador
player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	-- Esperar un frame para que el servidor aplique la velocidad guardada
	task.wait(0.1)
	UpdateCurrentSpeedDisplay()
end)

-- Función para enviar la velocidad al servidor cuando el jugador presiona Enter
textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local texto = textBox.Text
		local velocidadDeseada = tonumber(texto)
		
		-- Si es vacío, 0, o inválido → enviar 0 (significa "usar máximo")
		if texto == "" or velocidadDeseada == nil or velocidadDeseada == 0 then
			setCustomSpeedEvent:FireServer(0)
			textBox.Text = tostring(GetMaxSpeed())
		else
			setCustomSpeedEvent:FireServer(velocidadDeseada)
		end
	end
end)

-- Recibir respuesta del servidor con la velocidad final aplicada
setCustomSpeedEvent.OnClientEvent:Connect(function(velocidadFinal: number)
	-- Actualizar el TextBox con la velocidad que realmente se aplicó
	textBox.Text = tostring(velocidadFinal)
end)
