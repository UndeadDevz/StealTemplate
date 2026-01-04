--[[
	═══════════════════════════════════════════════════════════════════════
	INICIALIZADOR DE REMOTE EVENTS
	═══════════════════════════════════════════════════════════════════════
	
	Este script crea los RemoteEvents necesarios en ReplicatedStorage.
	Se ejecuta en el servidor al inicio del juego.
	
	═══════════════════════════════════════════════════════════════════════
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crea una carpeta para organizar los eventos
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
end

-- Crea el RemoteEvent para efectos de nivel
local efectoLvlUp = remoteEventsFolder:FindFirstChild("EfectoLvlUp")
if not efectoLvlUp then
	efectoLvlUp = Instance.new("RemoteEvent")
	efectoLvlUp.Name = "EfectoLvlUp"
	efectoLvlUp.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'EfectoLvlUp' creado")
end

-- Crea el RemoteEvent para cambiar velocidad personalizada
local setCustomSpeed = remoteEventsFolder:FindFirstChild("SetCustomSpeed")
if not setCustomSpeed then
	setCustomSpeed = Instance.new("RemoteEvent")
	setCustomSpeed.Name = "SetCustomSpeed"
	setCustomSpeed.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'SetCustomSpeed' creado")
end
