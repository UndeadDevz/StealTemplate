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
local BASE_SPEED = 16

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
local function UpdateMaxSpeedDisplay()
	local nivel = levelValue.Value
	local maxSpeed = BASE_SPEED + (nivel * 2)
	maxSpeedLabel.Text = tostring(maxSpeed)
end

-- Función para mostrar la velocidad actual en el TextBox
local function UpdateCurrentSpeedDisplay()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	textBox.Text = tostring(math.floor(humanoid.WalkSpeed))
end

-- Actualizar al inicio
UpdateMaxSpeedDisplay()
UpdateCurrentSpeedDisplay()

-- Actualizar cuando sube de nivel
levelValue.Changed:Connect(UpdateMaxSpeedDisplay)

-- Actualizar cuando respawnea el jugador
player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	-- Esperar un frame para que el servidor aplique la velocidad guardada
	task.wait(0.1)
	textBox.Text = tostring(math.floor(humanoid.WalkSpeed))
end)

-- Función para enviar la velocidad al servidor cuando el jugador presiona Enter
textBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local velocidadDeseada = tonumber(textBox.Text)
		
		if velocidadDeseada then
			-- Enviar al servidor para validación
			setCustomSpeedEvent:FireServer(velocidadDeseada)
		else
			-- Si no es un número válido, mostrar feedback
			textBox.Text = "Número inválido"
		end
	end
end)

-- Recibir respuesta del servidor con la velocidad final aplicada
setCustomSpeedEvent.OnClientEvent:Connect(function(velocidadFinal: number)
	-- Actualizar el TextBox con la velocidad que realmente se aplicó
	textBox.Text = tostring(velocidadFinal)
end)
