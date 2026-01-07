local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local DataManager = require(script.Parent.Parent.Data.DataManager)

--[[
	═══════════════════════════════════════════════════════════════════════
	GAMEPASSES (No necesitan ProcessReceipt)
	═══════════════════════════════════════════════════════════════════════

	x2 Wins GamePass (ID: 1661925212):
	- Configurado en WinsSystem.server.luau y X2WinsGamePassHandler.server.luau
	- Se verifica con MarketplaceService:UserOwnsGamePassAsync()
	- Beneficio: Multiplica TODAS las wins por 2 automáticamente
	- No necesita estar en esta lista de productos

	Multiplicadores GamePasses (STACKEABLES):
	- x2 Speed (ID: 1661939202) = +2
	- x4 Speed (ID: 1661865221) = +4
	- x8 Speed (ID: 1659993882) = +8
	- x16 Speed (ID: 1662049180) = +16
	- x32 Speed (ID: 1660305540) = +32
	- x64 Speed (ID: 1663886754) = +64
	- x128 Speed (ID: 1663886755) = +128
	- x256 Speed (ID: 1661041459) = +256
	- Configurado en MultiplierGamePassHandler.server.luau
	- Se suman todos los que tenga el jugador (ej: x2 + x4 = 6x total)
	- No necesitan estar en esta lista de productos

	═══════════════════════════════════════════════════════════════════════
]]

-- Configuración de TODOS los productos Developer Products (consumibles)
local PRODUCTOS = {

	-- [[ PACKS DE EXPERIENCIA (Consumibles) ]] --
	[3499890350] = { Type = "EXP", Value = 10000 },    -- 10k
	[3499900596] = { Type = "EXP", Value = 100000 },   -- 100k
	[3499900814] = { Type = "EXP", Value = 1000000 },  -- 1M

	-- [[ CHECKPOINT TELEPORT (Consumible) ]] --
	[3502953308] = { Type = "CheckpointTeleport", Value = 1 },

	-- [[ REBIRTH KEEP LEVEL (Consumible) ]] --
	[3505671943] = { Type = "RebirthKeepLevel", Value = 1 },  -- ⚠️ REEMPLAZAR 0 CON PRODUCT ID REAL

	-- [[ PISTAS DESBLOQUEABLES ]] --
	[3503497564] = { Type = "Track", Value = 3 },  -- Zona x3
	[3503499104] = { Type = "Track", Value = 5 },  -- Zona x5
	[3503499344] = { Type = "Track", Value = 9 },  -- Zona x9
	[3503499623] = { Type = "Track", Value = 25 }, -- Zona x25
}

local function ProcessReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)

	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = receiptInfo.ProductId
	local data = PRODUCTOS[productId]

	if data then
		-- LOGICA PARA EXP
		if data.Type == "EXP" then
			-- 1. Sumar la EXP
			DataManager.AddStat(player, "EXP", data.Value)

			-- 2. Verificar si sube de nivel inmediatamente
			DataManager.CheckLevelUp(player)

			print("✅ Pack comprado: +" .. data.Value .. " EXP")
			return Enum.ProductPurchaseDecision.PurchaseGranted

		-- LOGICA PARA CHECKPOINT TELEPORT
		elseif data.Type == "CheckpointTeleport" then
			print("💎 Checkpoint Teleport comprado por:", player.Name)

			-- Disparar evento para teleport al checkpoint
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
			local teleportEvent = remoteEvents:WaitForChild("TeleportToCheckpoint")
			teleportEvent:FireClient(player)

			return Enum.ProductPurchaseDecision.PurchaseGranted

		-- LOGICA PARA REBIRTH KEEP LEVEL
		elseif data.Type == "RebirthKeepLevel" then
			print("🌟 Rebirth Keep Level comprado por:", player.Name)

			-- Llamar a la función global exportada desde RebirthSystem
			if _G.RebirthKeepLevel then
				local success = _G.RebirthKeepLevel(player)
				if success then
					return Enum.ProductPurchaseDecision.PurchaseGranted
				else
					-- No cumple requisitos, no consumir compra
					return Enum.ProductPurchaseDecision.NotProcessedYet
				end
			else
				warn("[MarketplaceManager] _G.RebirthKeepLevel no está disponible")
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end

		-- LOGICA PARA PISTAS DESBLOQUEABLES
		elseif data.Type == "Track" then
			DataManager.UnlockTrack(player, data.Value)
			print("✅ Zona x" .. data.Value .. " comprada permanentemente.")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.ProcessReceipt = ProcessReceipt