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

	═══════════════════════════════════════════════════════════════════════
]]

-- Configuración de TODOS los productos Developer Products (consumibles)
local PRODUCTOS = {
	-- [[ MULTIPLICADORES (Mejoras permanentes) ]] --
	[1661939202] = { Type = "Multiplier", Value = 2 },
	[1661865221] = { Type = "Multiplier", Value = 4 },
	[1659993882] = { Type = "Multiplier", Value = 8 },
	[1662049180] = { Type = "Multiplier", Value = 16 },
	[1660305540] = { Type = "Multiplier", Value = 32 },
	[1663886754] = { Type = "Multiplier", Value = 64 },
	[1663886755] = { Type = "Multiplier", Value = 128 },
	[1661041459] = { Type = "Multiplier", Value = 256 },

	-- [[ PACKS DE EXPERIENCIA (Consumibles) ]] --
	[3499890350] = { Type = "EXP", Value = 10000 },    -- 10k
	[3499900596] = { Type = "EXP", Value = 100000 },   -- 100k
	[3499900814] = { Type = "EXP", Value = 1000000 },  -- 1M

	-- [[ CHECKPOINT TELEPORT (Consumible) ]] --
	[3502953308] = { Type = "CheckpointTeleport", Value = 1 },  -- ⚠️ REEMPLAZAR 0 CON PRODUCT ID REAL

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
		-- LOGICA PARA MULTIPLICADORES
		if data.Type == "Multiplier" then
			local currentMult = DataManager.GetStat(player, "Multiplier") or 1
			if data.Value > currentMult then
				DataManager.UpdateStat(player, "Multiplier", data.Value)
				print("✅ Mejora comprada: x" .. data.Value .. " Speed")
			end
			return Enum.ProductPurchaseDecision.PurchaseGranted

		-- LOGICA PARA EXP (NUEVO)
		elseif data.Type == "EXP" then
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