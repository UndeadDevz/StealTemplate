local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- Configuración de productos
local PRODUCTOS = {
	[3499797343] = { TargetMult = 2 },  -- x2
	[3499832232] = { TargetMult = 4 },  -- x4
	[3499832626] = { TargetMult = 8 },  -- x8
	[3499833065] = { TargetMult = 16 }, -- x16
}

local function ProcessReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	
	if not player then
		-- El jugador se fue antes de procesar, Roblox lo reintentará luego
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local productId = receiptInfo.ProductId
	local data = PRODUCTOS[productId]
	
	if data then
		local currentMult = DataManager.GetStat(player, "Multiplier") or 1
		
		-- Solo aplicamos si es una mejora (para evitar que compren uno menor por error)
		if data.TargetMult > currentMult then
			DataManager.UpdateStat(player, "Multiplier", data.TargetMult)
			print("✅ Compra exitosa: Multiplicador actualizado a x" .. data.TargetMult)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			print("⚠️ El jugador ya tenía un multiplicador igual o superior.")
			-- Aún así concedemos la compra para no cobrarle infinitamente sin cerrar la transacción
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
	
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketplaceService.ProcessReceipt = ProcessReceipt