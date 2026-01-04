--[[
	═══════════════════════════════════════════════════════════════════════
	SPEED BUTTONS HANDLER
	═══════════════════════════════════════════════════════════════════════
	
	Maneja los botones de compra de productos (EXP packs) en el GUI.
	Ubicación: Buttons > SpeedButtonsFrame > SpeedButton1/2/3
	
	═══════════════════════════════════════════════════════════════════════
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local buttonsGui = playerGui:WaitForChild("Buttons")
local speedButtonsFrame = buttonsGui:WaitForChild("SpeedButtonsFrame")

-- Configuración de botones e IDs
local BUTTONS_CONFIG = {
	{ ButtonName = "SpeedButton1", ProductId = 3499890350 }, -- 10k EXP
	{ ButtonName = "SpeedButton2", ProductId = 3499900596 }, -- 100k EXP
	{ ButtonName = "SpeedButton3", ProductId = 3499900814 }, -- 1M EXP
}

for _, config in ipairs(BUTTONS_CONFIG) do
	-- Buscar el botón por su nombre
	local btn = speedButtonsFrame:FindFirstChild(config.ButtonName)

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

print("✅ SpeedButtonsHandler inicializado")
