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
	{ ButtonName = "Buy100Win", ProductId = 3514238670 }, -- Buy100Win
	{ ButtonName = "Buy400Win", ProductId = 3514238956 }, -- Buy400Win
	{ ButtonName = "Buy1200Win", ProductId = 3514239409 }, -- Buy1200Win
	{ ButtonName = "Buy3500Win", ProductId = 3514239594 }, -- Buy3500Win
	{ ButtonName = "Buy12000Win", ProductId = 3514239931 }, -- Buy12000Win
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