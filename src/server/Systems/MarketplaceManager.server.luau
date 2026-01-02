local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- Configuración de TODOS los productos (Multiplicadores y EXP)
local PRODUCTOS = {
	-- [[ MULTIPLICADORES (Mejoras permanentes) ]] --
	[3499797343] = { Type = "Multiplier", Value = 2 },
	[3499832232] = { Type = "Multiplier", Value = 4 },
	[3499832626] = { Type = "Multiplier", Value = 8 },
	[3499833065] = { Type = "Multiplier", Value = 16 },

	-- [[ PACKS DE EXPERIENCIA (Consumibles) ]] --
	[3499890350] = { Type = "EXP", Value = 10000 },    -- 10k
	[3499900596] = { Type = "EXP", Value = 100000 },   -- 100k
	[3499900814] = { Type = "EXP", Value = 1000000 },  -- 1M
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
		end
	end
	
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.ProcessReceipt = ProcessReceipt