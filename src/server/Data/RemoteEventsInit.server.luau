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

-- Crea el RemoteFunction para obtener settings
local getSettings = remoteEventsFolder:FindFirstChild("GetSettings")
if not getSettings then
	getSettings = Instance.new("RemoteFunction")
	getSettings.Name = "GetSettings"
	getSettings.Parent = remoteEventsFolder
	print("✅ RemoteFunction 'GetSettings' creado")
end

-- Handler para GetSettings
getSettings.OnServerInvoke = function(player)
	return DataManager.GetSettings(player)
end

-- Crea el RemoteEvent para actualizar settings
local updateSettings = remoteEventsFolder:FindFirstChild("UpdateSettings")
if not updateSettings then
	updateSettings = Instance.new("RemoteEvent")
	updateSettings.Name = "UpdateSettings"
	updateSettings.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'UpdateSettings' creado")
end

-- Handler para UpdateSettings
updateSettings.OnServerEvent:Connect(function(player, settings)
	DataManager.UpdateSettings(player, settings)
end)

-- Crea el RemoteEvent para notificar sobre GamePass x2 Wins
local notifyX2WinsAvailable = remoteEventsFolder:FindFirstChild("NotifyX2WinsAvailable")
if not notifyX2WinsAvailable then
	notifyX2WinsAvailable = Instance.new("RemoteEvent")
	notifyX2WinsAvailable.Name = "NotifyX2WinsAvailable"
	notifyX2WinsAvailable.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'NotifyX2WinsAvailable' creado")
end

-- Crea el RemoteEvent para comprar GamePass x2 Wins
local promptX2WinsPurchase = remoteEventsFolder:FindFirstChild("PromptX2WinsPurchase")
if not promptX2WinsPurchase then
	promptX2WinsPurchase = Instance.new("RemoteEvent")
	promptX2WinsPurchase.Name = "PromptX2WinsPurchase"
	promptX2WinsPurchase.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'PromptX2WinsPurchase' creado")
end

-- Crea el RemoteEvent para notificar respawn gratis
local notifyFreeRespawn = remoteEventsFolder:FindFirstChild("NotifyFreeRespawn")
if not notifyFreeRespawn then
	notifyFreeRespawn = Instance.new("RemoteEvent")
	notifyFreeRespawn.Name = "NotifyFreeRespawn"
	notifyFreeRespawn.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'NotifyFreeRespawn' creado")
end

-- Crea el RemoteEvent para comprar GamePasses de multiplicador
local promptMultiplierPurchase = remoteEventsFolder:FindFirstChild("PromptMultiplierPurchase")
if not promptMultiplierPurchase then
	promptMultiplierPurchase = Instance.new("RemoteEvent")
	promptMultiplierPurchase.Name = "PromptMultiplierPurchase"
	promptMultiplierPurchase.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'PromptMultiplierPurchase' creado")
end

-- Crea el RemoteEvent para solicitar Rebirth Normal (gratis)
local requestRebirth = remoteEventsFolder:FindFirstChild("RequestRebirth")
if not requestRebirth then
	requestRebirth = Instance.new("RemoteEvent")
	requestRebirth.Name = "RequestRebirth"
	requestRebirth.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'RequestRebirth' creado")
end

-- Crea el RemoteEvent para solicitar Rebirth Keep Level (producto)
local requestRebirthKeepLevel = remoteEventsFolder:FindFirstChild("RequestRebirthKeepLevel")
if not requestRebirthKeepLevel then
	requestRebirthKeepLevel = Instance.new("RemoteEvent")
	requestRebirthKeepLevel.Name = "RequestRebirthKeepLevel"
	requestRebirthKeepLevel.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'RequestRebirthKeepLevel' creado")
end

-- Crea el RemoteEvent para notificar EXP ganada
local expGainedEvent = remoteEventsFolder:FindFirstChild("ExpGainedEvent")
if not expGainedEvent then
	expGainedEvent = Instance.new("RemoteEvent")
	expGainedEvent.Name = "ExpGainedEvent"
	expGainedEvent.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'ExpGainedEvent' creado")
end

-- Crea el RemoteEvent para cambiar el modelo del coche
local changeCarModel = remoteEventsFolder:FindFirstChild("ChangeCarModel")
if not changeCarModel then
	changeCarModel = Instance.new("RemoteEvent")
	changeCarModel.Name = "ChangeCarModel"
	changeCarModel.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'ChangeCarModel' creado")
end
