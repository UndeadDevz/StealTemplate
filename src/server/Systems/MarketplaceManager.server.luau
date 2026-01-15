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

	ZonasEXP GamePasses:
	- Zona x3, x5, x9, x25 (IDs configurados en ExpTraining.server.luau)
	- Se verifican con MarketplaceService:UserOwnsGamePassAsync()

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

	-- [[ POCIONES (Consumibles) ]] --
	[3513445425] = { Type = "Potion", Value = "SpeedPotion" },  -- Speed Potion
	[3513445564] = { Type = "Potion", Value = "WinsPotion" },   -- Wins Potion
	[3513445863] = { Type = "Potion", Value = "BundlePotion" }, -- Bundle (5 Speed + 5 Wins)
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

		-- LOGICA PARA POCIONES
		elseif data.Type == "Potion" then
			if data.Value == "SpeedPotion" then
				DataManager.AddToInventory(player, "SpeedPotion", 1)
				print("🧪 Speed Potion comprado por:", player.Name)
			elseif data.Value == "WinsPotion" then
				DataManager.AddToInventory(player, "WinsPotion", 1)
				print("🏆 Wins Potion comprado por:", player.Name)
			elseif data.Value == "BundlePotion" then
				DataManager.AddToInventory(player, "SpeedPotion", 100)
				DataManager.AddToInventory(player, "WinsPotion", 100)
				print("📦 Potion Bundle comprado por:", player.Name)
			end
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.ProcessReceipt = ProcessReceipt