local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Referencias a leaderstats (ajusta "Wins" si el nombre en tu carpeta es distinto)
local leaderstats = player:WaitForChild("leaderstats")
local winsAttribute = leaderstats:WaitForChild("Wins")

-- Módulos
local NumberFormatter = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("NumberFormatter"))

-- RemoteFunctions
local remoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local getExpBaseData = remoteFunctions:WaitForChild("GetExpBaseData")
local upgradeExpBase = remoteFunctions:WaitForChild("UpgradeExpBase")

-- Elementos de UI
local mainUI = playerGui:WaitForChild("MainUI")
local buttonsGui = playerGui:WaitForChild("Buttons") -- Referencia a ScreenGui Buttons
local lookHereStats = buttonsGui:FindFirstChild("LookHereStats", true) -- El signo de exclamación

local statsFrame = mainUI:WaitForChild("StatsFrame")
local fromToExpBaseLabel = statsFrame:FindFirstChild("FromToExpBase", true)
local winsNeededLabel = statsFrame:FindFirstChild("WinsNeeded", true)
local upgradeButton = statsFrame:FindFirstChild("UpgradeButton", true)

-- Función para verificar si mostramos la notificación (!)
local function checkNotification(data)
    print("[ExpBaseUpgradeUI] Checking notification..." .. tostring(data.upgradeCost))
    if not data or data.isMaxLevel then
        lookHereStats.Visible = false
        return
    end

    -- Si las Wins actuales son mayores o iguales al costo, mostrar
    if winsAttribute.Value >= data.upgradeCost then
        lookHereStats.Visible = true
    else
        lookHereStats.Visible = false
    end
end

-- Función para actualizar la UI
local function updateUI()
    local data = getExpBaseData:InvokeServer()

    if not data then return end

    -- Actualizar visibilidad de la alerta
    checkNotification(data)

    if data.isMaxLevel then
        fromToExpBaseLabel.Text = data.currentValue .. "/s"
        winsNeededLabel.Text = "MAX LEVEL"
        upgradeButton.Text = "Maxed"
        upgradeButton.Active = false
        upgradeButton.AutoButtonColor = false
    else
        fromToExpBaseLabel.Text = data.currentValue .. "/s  >  " .. data.nextValue .. "/s"
        winsNeededLabel.Text = NumberFormatter.Format(data.upgradeCost) .. " Wins"
        
        upgradeButton.Text = "UPGRADE"
        upgradeButton.Active = true
        upgradeButton.AutoButtonColor = true
    end
    
    return data -- Devolvemos data para usarlo en el evento Changed
end

-- Conectar el botón de upgrade
upgradeButton.MouseButton1Click:Connect(function()
    if not upgradeButton.Active then return end

    local result = upgradeExpBase:InvokeServer()
    if result.success then
        updateUI()
    else
        warn("Error: " .. result.message)
    end
end)

-- Actualizar notificación en tiempo real cuando cambien las Wins
winsAttribute.Changed:Connect(function()
    -- Pedimos la data de nuevo para comparar con el costo actual
    local data = getExpBaseData:InvokeServer()
    checkNotification(data)
end)

-- Inicializar UI
updateUI()