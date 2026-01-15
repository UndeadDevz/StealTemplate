local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainUI = playerGui:WaitForChild("MainUI")
local shopFrame = mainUI:WaitForChild("ShopFrame")

-- Configuración de botones e IDs
local BUTTONS_CONFIG = {
	{ ButtonName = "BuySpeedPotionButton", ProductId = 3513445425 }, -- Speed Potion
	{ ButtonName = "BuyWinPotionButton", ProductId = 3513445564 },   -- Wins Potion
	{ ButtonName = "BuyBundlePotionButton", ProductId = 3513445863 }, -- Bundle
}

for _, config in ipairs(BUTTONS_CONFIG) do
	-- Buscar el botón por su nombre
	local btn = shopFrame:FindFirstChild(config.ButtonName, true)

	if btn and btn:IsA("GuiButton") then
		btn.MouseButton1Click:Connect(function()
			-- Activar la ventana de compra de Roblox
			MarketplaceService:PromptProductPurchase(player, config.ProductId)
		end)
		print("✅ " .. config.ButtonName .. " conectado (ProductId: " .. config.ProductId .. ")")
	else
		warn("⚠️ No se encontró el botón: " .. config.ButtonName)
	end
end

print("✅ PotionShopHandler inicializado")