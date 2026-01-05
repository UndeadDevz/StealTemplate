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

-- Crea el RemoteEvent para mostrar popup de muerte
local showDeathPopup = remoteEventsFolder:FindFirstChild("ShowDeathPopup")
if not showDeathPopup then
	showDeathPopup = Instance.new("RemoteEvent")
	showDeathPopup.Name = "ShowDeathPopup"
	showDeathPopup.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'ShowDeathPopup' creado")
end

-- Crea el RemoteEvent para teleport a checkpoint
local teleportToCheckpoint = remoteEventsFolder:FindFirstChild("TeleportToCheckpoint")
if not teleportToCheckpoint then
	teleportToCheckpoint = Instance.new("RemoteEvent")
	teleportToCheckpoint.Name = "TeleportToCheckpoint"
	teleportToCheckpoint.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'TeleportToCheckpoint' creado")
end

-- Crea el RemoteFunction para obtener stats
local DataManager = require(script.Parent.DataManager)

local getStat = remoteEventsFolder:FindFirstChild("GetStat")
if not getStat then
	getStat = Instance.new("RemoteFunction")
	getStat.Name = "GetStat"
	getStat.Parent = remoteEventsFolder
	print("✅ RemoteFunction 'GetStat' creado")
end

-- Handler para GetStat
getStat.OnServerInvoke = function(player, statName)
	return DataManager.GetStat(player, statName)
end
