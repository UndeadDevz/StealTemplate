--[[
	═══════════════════════════════════════════════════════════════════════
	SPEED MULTIPLIER HANDLER
	═══════════════════════════════════════════════════════════════════════
	
	Maneja el botón de compra de multiplicadores de velocidad.
	Ubicación: Buttons > SpeedMultiplier (TextButton con PriceLabel y SpeedLabel)
	
	═══════════════════════════════════════════════════════════════════════
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local buttonsGui = playerGui:WaitForChild("Buttons")
local button = buttonsGui:WaitForChild("SpeedMultiplier")
local priceLabel = button:WaitForChild("PriceLabel")
local speedLabel = button:WaitForChild("SpeedLabel")

-- Configuración ordenada por niveles
local UPGRADES = {
	{ mult = 2,  id = 3499797343, price = 50 },
	{ mult = 4,  id = 3499832232, price = 100 },
	{ mult = 8,  id = 3499832626, price = 200 },
	{ mult = 16, id = 3499833065, price = 400 },
}

local currentProductID = nil

local function UpdateUI()
	local leaderstats = player:WaitForChild("leaderstats")
	local currentMult = leaderstats:WaitForChild("Multiplier").Value

	-- Buscar la SIGUIENTE mejora disponible
	local nextUpgrade = nil
	for _, upgrade in ipairs(UPGRADES) do
		if upgrade.mult > currentMult then
			nextUpgrade = upgrade
			break
		end
	end

	if nextUpgrade then
		-- Mostrar botón de compra
		button.Text = "x" .. nextUpgrade.mult .. " Speed"
		priceLabel.Text = "Only " .. nextUpgrade.price
		speedLabel.Text = "x" .. nextUpgrade.mult .. " Speed"
		currentProductID = nextUpgrade.id
		button.Visible = true
	else
		-- Ya tiene el máximo (x16)
		button.Text = "MAXED"
		speedLabel.Text = "MAXED"
		priceLabel.Text = "MAXED"
		currentProductID = nil
		-- Opcional: button.Visible = false
	end
end

-- Detectar clic
button.MouseButton1Click:Connect(function()
	if currentProductID then
		MarketplaceService:PromptProductPurchase(player, currentProductID)
	end
end)

-- Actualizar cuando cambie el stat (ej. después de comprar)
local leaderstats = player:WaitForChild("leaderstats")
local multStat = leaderstats:WaitForChild("Multiplier")

multStat.Changed:Connect(UpdateUI)
UpdateUI() -- Ejecutar al inicio

print("✅ SpeedMultiplierHandler inicializado")
