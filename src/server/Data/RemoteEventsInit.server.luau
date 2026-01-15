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
local remoteFunctionsFolder = ReplicatedStorage:FindFirstChild("RemoteFunctions")
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

-- Crea el RemoteEvent para solicitar recarga de personaje (el cliente no puede llamar LoadCharacter)
local requestReloadCharacter = remoteEventsFolder:FindFirstChild("RequestReloadCharacter")
if not requestReloadCharacter then
	requestReloadCharacter = Instance.new("RemoteEvent")
	requestReloadCharacter.Name = "RequestReloadCharacter"
	requestReloadCharacter.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'RequestReloadCharacter' creado")
end

-- Handler para RequestReloadCharacter
requestReloadCharacter.OnServerEvent:Connect(function(player)
	-- Validar que el jugador existe y puede recargar
	if player and player.Character then
		player:LoadCharacter()
	end
end)

-- Crea el RemoteEvent para notificar cambios en Wins
local winsChanged = remoteEventsFolder:FindFirstChild("WinsChanged")
if not winsChanged then
	winsChanged = Instance.new("RemoteEvent")
	winsChanged.Name = "WinsChanged"
	winsChanged.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'WinsChanged' creado")
end

-- Crea el RemoteFunction para reclamar recompensa de grupo
local claimGroupReward = remoteEventsFolder:FindFirstChild("ClaimGroupReward")
if not claimGroupReward then
	claimGroupReward = Instance.new("RemoteFunction")
	claimGroupReward.Name = "ClaimGroupReward"
	claimGroupReward.Parent = remoteEventsFolder
	print("✅ RemoteFunction 'ClaimGroupReward' creado")
end

-- Configuración de recompensa de grupo
local GROUP_ID = 1035894336
local GROUP_REWARD_EXP = 10000
local _GroupService = game:GetService("GroupService")

-- Handler para ClaimGroupReward
-- Retorna: { success: boolean, message: string, alreadyClaimed: boolean, inGroup: boolean }
claimGroupReward.OnServerInvoke = function(player)
	local profile = DataManager.Profiles[player]
	if not profile then
		return { success = false, message = "Error de datos", alreadyClaimed = false, inGroup = false }
	end

	-- Verificar si ya reclamó
	if profile.Data.GroupRewardClaimed then
		return { success = false, message = "Ya reclamaste esta recompensa", alreadyClaimed = true, inGroup = true }
	end

	-- Verificar si está en el grupo
	local inGroup = false
	local success, result = pcall(function()
		return player:IsInGroup(GROUP_ID)
	end)

	if success then
		inGroup = result
	end

	if not inGroup then
		return { success = false, message = "Debes unirte al grupo primero", alreadyClaimed = false, inGroup = false }
	end

	-- Dar la recompensa (EXP para nivel + TotalEXP para leaderboard)
	profile.Data.EXP = profile.Data.EXP + GROUP_REWARD_EXP
	profile.Data.TotalEXP = profile.Data.TotalEXP + GROUP_REWARD_EXP
	profile.Data.GroupRewardClaimed = true

	-- Actualizar leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local speedStat = leaderstats:FindFirstChild("Speed")
		if speedStat then
			speedStat.Value = profile.Data.TotalEXP
		end
	end

	-- Verificar si sube de nivel
	local levelsGained = DataManager.CheckLevelUp(player)
	if levelsGained > 0 then
		print("✅ " .. player.Name .. " subió " .. levelsGained .. " niveles con la recompensa de grupo!")
	end

	print("✅ " .. player.Name .. " reclamó recompensa de grupo: " .. GROUP_REWARD_EXP .. " EXP")
	return { success = true, message = "¡Recibiste " .. GROUP_REWARD_EXP .. " EXP!", alreadyClaimed = false, inGroup = true }
end

-- Crea el RemoteFunction para usar pociones
local usePotion = remoteFunctionsFolder:FindFirstChild("UsePotion")
if not usePotion then
	usePotion = Instance.new("RemoteFunction")
	usePotion.Name = "UsePotion"
	usePotion.Parent = remoteFunctionsFolder
	print("✅ RemoteFunction 'UsePotion' creado")
end

-- Handler para UsePotion
usePotion.OnServerInvoke = function(player, potionType)
	local countStat = potionType .. "Count"
	local remainingStat = potionType .. "Remaining"
	local duration = 300  -- 5 minutes

	local currentCount = DataManager.GetStat(player, countStat) or 0
	if currentCount > 0 then
		DataManager.AddStat(player, countStat, -1)
		local currentRemaining = DataManager.GetStat(player, remainingStat) or 0
		local newRemaining = currentRemaining + duration
		DataManager.UpdateStat(player, remainingStat, newRemaining)
		
		-- Notify client
		local buffActivatedEvent = remoteEventsFolder:FindFirstChild("BuffActivated")
		if buffActivatedEvent then
			buffActivatedEvent:FireClient(player, potionType, newRemaining)
		end
		return true
	end
	return false
end

-- Crea el RemoteEvent para activar buff
local buffActivated = remoteEventsFolder:FindFirstChild("BuffActivated")
if not buffActivated then
	buffActivated = Instance.new("RemoteEvent")
	buffActivated.Name = "BuffActivated"
	buffActivated.Parent = remoteEventsFolder
	print("✅ RemoteEvent 'BuffActivated' creado")
end
