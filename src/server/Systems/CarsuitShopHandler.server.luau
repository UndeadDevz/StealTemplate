--[[
	CarsuitShopHandler - Sistema de tienda de Carsuits via UI

	RemoteFunctions:
	- GetAllCarsuits: Obtiene lista de todos los carsuits con su estado
	- EquipCarsuit: Equipa un carsuit (si esta desbloqueado)
	- UnlockCarsuitWins: Desbloquea un carsuit con Wins

	RemoteEvents:
	- CarsuitUnlocked: Notifica cuando se desbloquea un carsuit
	- CarsuitEquipped: Notifica cuando se equipa un carsuit
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local DataManager = require(script.Parent.Parent.Data.DataManager)
local CarsuitUnlockConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CarsuitUnlockConfig"))
local CarConfigs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CarConfigs"))

-- Crear carpeta de RemoteFunctions si no existe
local remoteFunctions = ReplicatedStorage:FindFirstChild("RemoteFunctions")
if not remoteFunctions then
	remoteFunctions = Instance.new("Folder")
	remoteFunctions.Name = "RemoteFunctions"
	remoteFunctions.Parent = ReplicatedStorage
end

-- Crear carpeta de RemoteEvents si no existe
local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEvents then
	remoteEvents = Instance.new("Folder")
	remoteEvents.Name = "RemoteEvents"
	remoteEvents.Parent = ReplicatedStorage
end

-- RemoteFunction: GetAllCarsuits
local getAllCarsuits = remoteFunctions:FindFirstChild("GetAllCarsuits")
if not getAllCarsuits then
	getAllCarsuits = Instance.new("RemoteFunction")
	getAllCarsuits.Name = "GetAllCarsuits"
	getAllCarsuits.Parent = remoteFunctions
end

-- RemoteFunction: EquipCarsuit
local equipCarsuit = remoteFunctions:FindFirstChild("EquipCarsuit")
if not equipCarsuit then
	equipCarsuit = Instance.new("RemoteFunction")
	equipCarsuit.Name = "EquipCarsuit"
	equipCarsuit.Parent = remoteFunctions
end

-- RemoteFunction: UnlockCarsuitWins
local unlockCarsuitWins = remoteFunctions:FindFirstChild("UnlockCarsuitWins")
if not unlockCarsuitWins then
	unlockCarsuitWins = Instance.new("RemoteFunction")
	unlockCarsuitWins.Name = "UnlockCarsuitWins"
	unlockCarsuitWins.Parent = remoteFunctions
end

-- RemoteEvent: CarsuitUnlocked
local carsuitUnlocked = remoteEvents:FindFirstChild("CarsuitUnlocked")
if not carsuitUnlocked then
	carsuitUnlocked = Instance.new("RemoteEvent")
	carsuitUnlocked.Name = "CarsuitUnlocked"
	carsuitUnlocked.Parent = remoteEvents
end

-- RemoteEvent: CarsuitEquipped
local carsuitEquipped = remoteEvents:FindFirstChild("CarsuitEquipped")
if not carsuitEquipped then
	carsuitEquipped = Instance.new("RemoteEvent")
	carsuitEquipped.Name = "CarsuitEquipped"
	carsuitEquipped.Parent = remoteEvents
end

-- RemoteEvent existente para cambiar modelo visual
local changeCarModel = remoteEvents:WaitForChild("ChangeCarModel")

-- Funcion auxiliar: Verificar si el jugador tiene un carsuit desbloqueado
local function HasCarsuit(player, equipType)
	local unlockedCarsuits = DataManager.GetStat(player, "UnlockedCarsuits")
	if not unlockedCarsuits then return false end
	return table.find(unlockedCarsuits, equipType) ~= nil
end

-- Funcion auxiliar: Desbloquear un carsuit
local function UnlockCarsuit(player, equipType)
	local profile = DataManager.Profiles[player]
	if not profile then return false end

	local unlockedCarsuits = profile.Data.UnlockedCarsuits or {}

	-- Verificar si ya lo tiene
	if table.find(unlockedCarsuits, equipType) then
		return true -- Ya desbloqueado
	end

	-- Agregar a la lista
	table.insert(unlockedCarsuits, equipType)
	profile.Data.UnlockedCarsuits = unlockedCarsuits

	-- Notificar al cliente
	carsuitUnlocked:FireClient(player, equipType)

	return true
end

-- Funcion auxiliar: Verificar ownership de GamePass
local function PlayerOwnsGamePass(player, gamePassId)
	if not gamePassId or gamePassId == 0 then return false end

	local success, ownsPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
	end)

	return success and ownsPass
end

-- Handler: GetAllCarsuits
-- Retorna lista de carsuits con estado: {equipType, displayName, unlockType, cost, isUnlocked, isEquipped, textureId}
getAllCarsuits.OnServerInvoke = function(player)
	local unlockedCarsuits = DataManager.GetStat(player, "UnlockedCarsuits") or {}
	local currentEquipType = DataManager.GetStat(player, "EquipType") or 1
	local playerWins = DataManager.GetStat(player, "Wins") or 0

	local carsuits = {}

	-- Usar GetAllEquipTypes para obtener solo los equipTypes (no las funciones)
	local allEquipTypes = CarsuitUnlockConfig.GetAllEquipTypes()

	for _, equipType in ipairs(allEquipTypes) do
		local unlockInfo = CarsuitUnlockConfig.GetUnlockInfo(equipType)
		if not unlockInfo then continue end

		local carConfig = CarConfigs[equipType]
		local isUnlocked = table.find(unlockedCarsuits, equipType) ~= nil

		-- Verificar GamePass si aplica
		if not isUnlocked and unlockInfo.UnlockType == "GamePass" then
			if PlayerOwnsGamePass(player, unlockInfo.GamePassId) then
				-- Desbloquear automaticamente
				UnlockCarsuit(player, equipType)
				isUnlocked = true
			end
		end

		-- Verificar Free si aplica
		if not isUnlocked and unlockInfo.UnlockType == "Free" then
			UnlockCarsuit(player, equipType)
			isUnlocked = true
		end

		table.insert(carsuits, {
			equipType = equipType,
			displayName = unlockInfo.DisplayName or ("Carsuit " .. equipType),
			unlockType = unlockInfo.UnlockType,
			cost = unlockInfo.Cost,
			gamePassId = unlockInfo.GamePassId,
			eventId = unlockInfo.EventId,
			isUnlocked = isUnlocked,
			isEquipped = currentEquipType == equipType,
			textureId = carConfig and carConfig.TextureID or nil,
			modelName = carConfig and carConfig.ModelName or nil,
			canAfford = unlockInfo.UnlockType == "Wins" and playerWins >= (unlockInfo.Cost or 0),
		})
	end

	-- Ordenar por equipType
	table.sort(carsuits, function(a, b)
		return a.equipType < b.equipType
	end)

	return {
		carsuits = carsuits,
		playerWins = playerWins,
		currentEquipType = currentEquipType,
	}
end

-- Handler: EquipCarsuit
-- Retorna: {success, message}
equipCarsuit.OnServerInvoke = function(player, equipType)
	-- Validar parametro
	if type(equipType) ~= "number" then
		return {
			success = false,
			message = "EquipType invalido",
		}
	end

	-- Verificar si existe el carsuit
	local unlockInfo = CarsuitUnlockConfig.GetUnlockInfo(equipType)
	if not unlockInfo then
		return {
			success = false,
			message = "Carsuit no existe",
		}
	end

	-- Verificar si ya lo tiene equipado
	local currentEquip = DataManager.GetStat(player, "EquipType") or 1
	if currentEquip == equipType then
		return {
			success = false,
			message = "Ya tienes este carsuit equipado",
		}
	end

	-- Verificar si tiene el carsuit desbloqueado
	if not HasCarsuit(player, equipType) then
		return {
			success = false,
			message = "No tienes este carsuit desbloqueado",
		}
	end

	-- Equipar
	DataManager.UpdateStat(player, "EquipType", equipType)
	player:SetAttribute("EquipType", equipType)

	-- Notificar a todos los clientes para cambiar modelo visual
	changeCarModel:FireAllClients(player, equipType)

	-- Notificar al cliente
	carsuitEquipped:FireClient(player, equipType)

	print("[CarsuitShop] " .. player.Name .. " equipo carsuit " .. equipType)

	return {
		success = true,
		message = "Carsuit equipado",
	}
end

-- Handler: UnlockCarsuitWins
-- Retorna: {success, message, newWins?}
unlockCarsuitWins.OnServerInvoke = function(player, equipType)
	-- Validar parametro
	if type(equipType) ~= "number" then
		return {
			success = false,
			message = "EquipType invalido",
		}
	end

	-- Verificar si existe el carsuit
	local unlockInfo = CarsuitUnlockConfig.GetUnlockInfo(equipType)
	if not unlockInfo then
		return {
			success = false,
			message = "Carsuit no existe",
		}
	end

	-- Verificar si ya lo tiene desbloqueado
	if HasCarsuit(player, equipType) then
		return {
			success = false,
			message = "Ya tienes este carsuit desbloqueado",
		}
	end

	-- Verificar si es desbloqueable con Wins
	if unlockInfo.UnlockType ~= "Wins" then
		return {
			success = false,
			message = "Este carsuit no se puede desbloquear con Wins",
		}
	end

	-- Verificar si tiene suficientes Wins
	local playerWins = DataManager.GetStat(player, "Wins") or 0
	local cost = unlockInfo.Cost or 0

	if playerWins < cost then
		return {
			success = false,
			message = "No tienes suficientes Wins. Necesitas " .. cost .. " Wins.",
		}
	end

	-- Desbloquear
	local newWins = playerWins - cost
	DataManager.UpdateStat(player, "Wins", newWins)
	UnlockCarsuit(player, equipType)

	print("[CarsuitShop] " .. player.Name .. " desbloqueo carsuit " .. equipType .. " por " .. cost .. " Wins")

	return {
		success = true,
		message = "Carsuit desbloqueado",
		newWins = newWins,
	}
end

-- ============================================
-- BINDABLE FUNCTION PARA OTROS SCRIPTS DEL SERVIDOR
-- ============================================
-- Usar desde otros scripts:
--   local grantCarsuit = ServerScriptService.Systems.CarsuitShopHandler:WaitForChild("GrantCarsuit")
--   local result = grantCarsuit:Invoke(player, equipType)

local ServerScriptService = game:GetService("ServerScriptService")

local grantCarsuitBindable = Instance.new("BindableFunction")
grantCarsuitBindable.Name = "GrantCarsuit"
grantCarsuitBindable.Parent = script

-- Funcion publica para desbloquear carsuit desde otros scripts del servidor
-- @param player: Player - El jugador
-- @param equipType: number - El ID del carsuit a desbloquear
-- @return {success: boolean, message: string}
grantCarsuitBindable.OnInvoke = function(player, equipType)
	-- Validar parametros
	if not player or not player:IsA("Player") then
		return {
			success = false,
			message = "Player invalido",
		}
	end

	if type(equipType) ~= "number" then
		return {
			success = false,
			message = "EquipType invalido",
		}
	end

	-- Verificar si existe el carsuit
	local unlockInfo = CarsuitUnlockConfig.GetUnlockInfo(equipType)
	if not unlockInfo then
		return {
			success = false,
			message = "Carsuit no existe",
		}
	end

	-- Verificar si ya lo tiene
	if HasCarsuit(player, equipType) then
		return {
			success = false,
			message = "El jugador ya tiene este carsuit",
		}
	end

	-- Desbloquear el carsuit
	local unlocked = UnlockCarsuit(player, equipType)

	if unlocked then
		print("[CarsuitShop] GRANT: " .. player.Name .. " recibio carsuit " .. equipType)
		return {
			success = true,
			message = "Carsuit desbloqueado exitosamente",
		}
	else
		return {
			success = false,
			message = "Error al desbloquear carsuit",
		}
	end
end

print("[CarsuitShopHandler] Sistema inicializado")
