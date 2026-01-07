--[[
	═══════════════════════════════════════════════════════════════════════
	MULTIPLIER GAMEPASS HANDLER
	═══════════════════════════════════════════════════════════════════════

	Sistema que verifica todos los GamePasses de multiplicador que tiene el
	jugador y los STACKEA (suma).

	GamePasses de Multiplicador:
	- x2 Speed (ID: 1661939202) = +2
	- x4 Speed (ID: 1661865221) = +4
	- x8 Speed (ID: 1659993882) = +8
	- x16 Speed (ID: 1662049180) = +16
	- x32 Speed (ID: 1660305540) = +32
	- x64 Speed (ID: 1663886754) = +64
	- x128 Speed (ID: 1663886755) = +128
	- x256 Speed (ID: 1661041459) = +256

	Si un jugador tiene x2 + x4 + x8 = Total Multiplier: 14x

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- ========== CONFIGURACIÓN ==========
local MULTIPLIER_GAMEPASSES = {
	{ ID = 1661939202, Value = 2 },
	{ ID = 1661865221, Value = 4 },
	{ ID = 1659993882, Value = 8 },
	{ ID = 1662049180, Value = 16 },
	{ ID = 1660305540, Value = 32 },
	{ ID = 1663886754, Value = 64 },
	{ ID = 1663886755, Value = 128 },
	{ ID = 1661041459, Value = 256 },
}
-- ===================================

-- Cache para evitar múltiples llamadas a la API
local gamePassCache = {}

-- Función para verificar un GamePass específico
local function PlayerOwnsGamePass(player, gamePassId)
	local userId = player.UserId

	-- Verificar en cache primero
	if gamePassCache[userId] and gamePassCache[userId][gamePassId] ~= nil then
		return gamePassCache[userId][gamePassId]
	end

	-- Verificar con la API de Roblox
	local success, ownsPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, gamePassId)
	end)

	if success then
		-- Guardar en cache
		if not gamePassCache[userId] then
			gamePassCache[userId] = {}
		end
		gamePassCache[userId][gamePassId] = ownsPass
		return ownsPass
	else
		warn("[MultiplierGamePassHandler] Error al verificar GamePass", gamePassId, ":", ownsPass)
		return false
	end
end

-- Función para calcular el multiplicador total del jugador
local function CalculateTotalMultiplier(player)
	local totalMultiplier = 0

	for _, gamePass in ipairs(MULTIPLIER_GAMEPASSES) do
		local owns = PlayerOwnsGamePass(player, gamePass.ID)

		if owns then
			totalMultiplier = totalMultiplier + gamePass.Value
		end
	end

	-- Si no tiene ningún GamePass, el multiplicador es 1 (base)
	if totalMultiplier == 0 then
		totalMultiplier = 1
	end

	return totalMultiplier
end

-- Función para actualizar el multiplicador de un jugador
local function UpdatePlayerMultiplier(player)
	local totalMult = CalculateTotalMultiplier(player)
	DataManager.UpdateStat(player, "Multiplier", totalMult)
	print("📊 " .. player.Name .. " - Multiplicador actualizado: " .. totalMult .. "x")
	return totalMult -- Retornar el multiplicador para verificación
end

-- Cuando un jugador entra, calcular su multiplicador
Players.PlayerAdded:Connect(function(player)
	-- Esperar a que sus stats se carguen
	task.wait(2)

	UpdatePlayerMultiplier(player)
end)

-- Cuando un jugador se va, limpiar cache
Players.PlayerRemoving:Connect(function(player)
	gamePassCache[player.UserId] = nil
end)

-- Actualizar jugadores que ya están en el juego
for _, player in pairs(Players:GetPlayers()) do
	task.spawn(function()
		task.wait(2)
		UpdatePlayerMultiplier(player)
	end)
end

-- Sistema de actualización periódica (cada 30 segundos)
task.spawn(function()
	while true do
		task.wait(30)

		for _, player in pairs(Players:GetPlayers()) do
			-- Limpiar cache para forzar re-verificación
			if gamePassCache[player.UserId] then
				gamePassCache[player.UserId] = nil
			end

			UpdatePlayerMultiplier(player)
		end
	end
end)

-- Detectar cuando un jugador compra un GamePass de multiplicador
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then return end

	-- Verificar si es uno de los GamePasses de multiplicador
	local isMultiplierGamePass = false
	for _, gamePass in ipairs(MULTIPLIER_GAMEPASSES) do
		if gamePass.ID == gamePassId then
			isMultiplierGamePass = true
			break
		end
	end

	if isMultiplierGamePass then
		-- Limpiar cache para forzar re-verificación
		if gamePassCache[player.UserId] then
			gamePassCache[player.UserId][gamePassId] = nil
		end

		-- Intentar actualizar varias veces (la API de Roblox puede tardar)
		task.wait(3)

		-- Intentar hasta 5 veces con delays
		for i = 1, 5 do
			local newMult = UpdatePlayerMultiplier(player)

			-- Si el multiplicador aumentó, la compra se procesó
			if newMult > 1 then
				print("🎉 " .. player.Name .. " compró GamePass de multiplicador! Total: " .. newMult .. "x")
				break
			else
				task.wait(2)
			end
		end
	end
end)

-- Exportar función para uso manual
_G.UpdatePlayerMultiplier = UpdatePlayerMultiplier

-- Handler para cuando el cliente pide comprar un GamePass de multiplicador
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local promptMultiplierPurchase = remoteEvents:WaitForChild("PromptMultiplierPurchase")

promptMultiplierPurchase.OnServerEvent:Connect(function(player, gamePassId)
	-- Asegurar que sea número
	local numericId = tonumber(gamePassId)
	if not numericId then
		warn("[MultiplierGamePassHandler] gamePassId no es un número:", gamePassId)
		return
	end

	-- Verificar que el ID sea válido
	local isValid = false
	for _, gamePass in ipairs(MULTIPLIER_GAMEPASSES) do
		if gamePass.ID == numericId then
			isValid = true
			break
		end
	end

	if not isValid then
		warn("[MultiplierGamePassHandler] GamePass ID inválido:", numericId)
		return
	end

	-- Mostrar prompt de compra
	task.spawn(function()
		local success, err = pcall(function()
			MarketplaceService:PromptGamePassPurchase(player, numericId)
		end)

		if not success then
			warn("[MultiplierGamePassHandler] Error al mostrar prompt:", err)
		end
	end)
end)

print("[MultiplierGamePassHandler] ✅ Sistema inicializado")
