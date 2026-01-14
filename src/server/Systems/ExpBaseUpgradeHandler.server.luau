--[[
	ExpBaseUpgradeHandler - Sistema de mejora de ExpBase via UI

	RemoteFunctions:
	- GetExpBaseData: Obtiene datos actuales de ExpBase del jugador
	- UpgradeExpBase: Mejora el nivel de ExpBase (gasta Wins)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)
local ExpBaseConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ExpBaseConfig"))

-- Crear carpeta de RemoteFunctions si no existe
local remoteFunctions = ReplicatedStorage:FindFirstChild("RemoteFunctions")
if not remoteFunctions then
	remoteFunctions = Instance.new("Folder")
	remoteFunctions.Name = "RemoteFunctions"
	remoteFunctions.Parent = ReplicatedStorage
end

-- RemoteFunction: GetExpBaseData
local getExpBaseData = remoteFunctions:FindFirstChild("GetExpBaseData")
if not getExpBaseData then
	getExpBaseData = Instance.new("RemoteFunction")
	getExpBaseData.Name = "GetExpBaseData"
	getExpBaseData.Parent = remoteFunctions
end

-- RemoteFunction: UpgradeExpBase
local upgradeExpBase = remoteFunctions:FindFirstChild("UpgradeExpBase")
if not upgradeExpBase then
	upgradeExpBase = Instance.new("RemoteFunction")
	upgradeExpBase.Name = "UpgradeExpBase"
	upgradeExpBase.Parent = remoteFunctions
end

-- Handler: GetExpBaseData
-- Retorna: {currentLevel, currentValue, nextLevel, nextValue, upgradeCost, playerWins, isMaxLevel}
getExpBaseData.OnServerInvoke = function(player)
	local currentLevel = DataManager.GetStat(player, "ExpBaseLevel") or 1
	local currentValue = DataManager.GetStat(player, "ExpBase") or 1
	local playerWins = DataManager.GetStat(player, "Wins") or 0

	local nextLevel = ExpBaseConfig.GetNextLevel(currentLevel)
	local isMaxLevel = nextLevel == nil

	local nextValue = 0
	local upgradeCost = 0

	if not isMaxLevel then
		nextValue = ExpBaseConfig.GetExpBaseValue(nextLevel)
		upgradeCost = ExpBaseConfig.GetWinsCost(nextLevel)
	end

	return {
		currentLevel = currentLevel,
		currentValue = currentValue,
		nextLevel = nextLevel,
		nextValue = nextValue,
		upgradeCost = upgradeCost,
		playerWins = playerWins,
		isMaxLevel = isMaxLevel,
	}
end

-- Handler: UpgradeExpBase
-- Retorna: {success, message, newLevel?, newValue?, newWins?}
upgradeExpBase.OnServerInvoke = function(player)
	local currentLevel = DataManager.GetStat(player, "ExpBaseLevel") or 1
	local playerWins = DataManager.GetStat(player, "Wins") or 0

	-- Verificar si ya esta en el nivel maximo
	local nextLevel = ExpBaseConfig.GetNextLevel(currentLevel)
	if not nextLevel then
		return {
			success = false,
			message = "Ya tienes el nivel maximo de ExpBase",
		}
	end

	-- Obtener costo de la mejora
	local upgradeCost = ExpBaseConfig.GetWinsCost(nextLevel)

	-- Verificar si tiene suficientes Wins
	if playerWins < upgradeCost then
		return {
			success = false,
			message = "No tienes suficientes Wins. Necesitas " .. upgradeCost .. " Wins.",
		}
	end

	-- Realizar la mejora
	local newExpBase = ExpBaseConfig.GetExpBaseValue(nextLevel)
	local newWins = playerWins - upgradeCost

	DataManager.UpdateStat(player, "ExpBaseLevel", nextLevel)
	DataManager.UpdateStat(player, "ExpBase", newExpBase)
	DataManager.UpdateStat(player, "Wins", newWins)

	print("[ExpBaseUpgrade] " .. player.Name .. " mejoro a ExpBase nivel " .. nextLevel .. " (valor: " .. newExpBase .. ")")

	return {
		success = true,
		message = "ExpBase mejorado a nivel " .. nextLevel,
		newLevel = nextLevel,
		newValue = newExpBase,
		newWins = newWins,
	}
end

print("[ExpBaseUpgradeHandler] Sistema inicializado")
