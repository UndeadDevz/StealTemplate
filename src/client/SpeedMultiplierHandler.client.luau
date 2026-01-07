--[[
	═══════════════════════════════════════════════════════════════════════
	SPEED MULTIPLIER HANDLER
	═══════════════════════════════════════════════════════════════════════
	
	Maneja el botón de compra de multiplicadores de velocidad.
	Ubicación: Buttons > SpeedMultiplier (TextButton con PriceLabel y SpeedLabel)
	
	═══════════════════════════════════════════════════════════════════════
]]

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local buttonsGui = playerGui:WaitForChild("Buttons")
local button = buttonsGui:WaitForChild("SpeedMultiplier")
local priceLabel = button:WaitForChild("PriceLabel")
local speedLabel = button:WaitForChild("SpeedLabel")

-- Esperar RemoteFunction
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local getStat = remoteEvents:WaitForChild("GetStat")

-- Configuración ordenada por niveles
local UPGRADES = {
	{ mult = 2,  id = 1661939202, price = 5 },
	{ mult = 4,  id = 1661865221, price = 9 },
	{ mult = 8,  id = 1659993882, price = 19 },
	{ mult = 16, id = 1662049180, price = 49 },
	{ mult = 32, id = 1660305540, price = 89 },
	{ mult = 64, id = 1663886754, price = 179 },
	{ mult = 128, id = 1663886755, price = 289 },
	{ mult = 256, id = 1661041459, price = 599 },
}

local currentProductID = nil

local function UpdateUI()
	local currentMult = getStat:InvokeServer("Multiplier")
	
	-- Si currentMult es nil, esperar
	if not currentMult then
		return
	end

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
		priceLabel.Text = "Only " .. utf8.char(0xE002) .. nextUpgrade.price
		speedLabel.Text = "x" .. nextUpgrade.mult .. " Speed"
		currentProductID = nextUpgrade.id
		button.Visible = true
	else
		-- Ya tiene el máximo (x128)
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

-- Actualizar cada 1 segundo para detectar cambios en Multiplier
task.spawn(function()
	while task.wait(1) do
		UpdateUI()
	end
end)

UpdateUI() -- Ejecutar al inicio

print("✅ SpeedMultiplierHandler inicializado")
