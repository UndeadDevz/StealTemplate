--[[
	CarsuitInventoryUI - Maneja la UI de inventario de carsuits

	Ubicacion esperada de UI:
	- StarterGui/MainUI/InventoryFrame
	- SmallCard es el template dentro de CarScrollingFrame
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberFormatter = require(ReplicatedStorage.Shared.Utils.NumberFormatter)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar a que cargue la UI
local mainUI = playerGui:WaitForChild("MainUI")
local inventoryFrame = mainUI:WaitForChild("InventoryFrame")
local carScrollingFrame = inventoryFrame:WaitForChild("CarScrollingFrame")

-- RemoteFunctions
local remoteFunctions = ReplicatedStorage:WaitForChild("RemoteFunctions")
local getAllCarsuits = remoteFunctions:WaitForChild("GetAllCarsuits")
local equipCarsuit = remoteFunctions:WaitForChild("EquipCarsuit")
local unlockCarsuitWins = remoteFunctions:WaitForChild("UnlockCarsuitWins")

-- RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local carsuitUnlocked = remoteEvents:WaitForChild("CarsuitUnlocked")
local carsuitEquipped = remoteEvents:WaitForChild("CarsuitEquipped")

-- Configuracion de colores
local COLORS = {
	Locked = Color3.fromRGB(80, 80, 80),      -- Gris para bloqueados
	Unlocked = Color3.fromRGB(50, 150, 50),   -- Verde para desbloqueados
	Equipped = Color3.fromRGB(50, 100, 200),  -- Azul para equipado
	CanAfford = Color3.fromRGB(200, 180, 50), -- Amarillo si puede comprar
}

-- Buscar el template de SmallCard
local cardTemplate = nil
for _, child in ipairs(carScrollingFrame:GetChildren()) do
	if child:IsA("Frame") and child.Name == "SmallCard" then
		cardTemplate = child:Clone()
		break
	end
end

if not cardTemplate then
	warn("[CarsuitInventoryUI] No se encontro template SmallCard en CarScrollingFrame")
	return
end

-- Limpiar cards existentes (excepto UIListLayout y otros componentes de UI)
local function ClearCards()
	for _, child in ipairs(carScrollingFrame:GetChildren()) do
		-- Eliminar todas las cards (empiezan con "SmallCard")
		if child:IsA("Frame") and string.sub(child.Name, 1, 9) == "SmallCard" then
			child:Destroy()
		end
	end
end

-- Crear una card para un carsuit
local function CreateCarsuitCard(carsuitData)
	local card = cardTemplate:Clone()
	card.Name = "SmallCard_" .. carsuitData.equipType

	-- Nombre del coche
	local carName = card:FindFirstChild("CarName")
	if carName then
		carName.Text = carsuitData.displayName or ("Car " .. carsuitData.equipType)
	end

	-- Label de equipado
	local equippedLabel = card:FindFirstChild("EquippedLabel")
	if equippedLabel then
		equippedLabel.Visible = carsuitData.isEquipped
	end

	-- Configurar color segun estado
	local uiStroke = card:FindFirstChild("UIStroke")
	if uiStroke then
		if carsuitData.isEquipped then
			uiStroke.Color = COLORS.Equipped
		elseif carsuitData.isUnlocked then
			uiStroke.Color = COLORS.Unlocked
		elseif carsuitData.canAfford then
			uiStroke.Color = COLORS.CanAfford
		else
			uiStroke.Color = COLORS.Locked
		end
	end

	-- Texto de costo o estado
	local textLabel = card:FindFirstChild("TextLabel")
	local imageLabel = card:FindFirstChild("ImageLabel")
	if textLabel then
		if carsuitData.isEquipped then
			textLabel.Visible = false
			imageLabel.Visible = false
		elseif carsuitData.isUnlocked then
			textLabel.Visible = false
			imageLabel.Visible = false
		elseif carsuitData.unlockType == "Wins" then
			textLabel.Text = NumberFormatter.Format(carsuitData.cost)
			textLabel.Visible = true
			imageLabel.Visible = true
		elseif carsuitData.unlockType == "GamePass" or carsuitData.unlockType == "Robux" then
			textLabel.Text = "See in Shop"
			textLabel.Visible = true
		elseif carsuitData.unlockType == "Event" then
			textLabel.Text = "Event Item"
			textLabel.Visible = true
		else
			textLabel.Visible = false
		end
	end

	-- Boton de accion (si existe TextButton)
	local actionButton = card:FindFirstChild("TextButton")
	if actionButton then
		-- Limpiar scripts existentes del template que puedan interferir
		for _, child in ipairs(actionButton:GetChildren()) do
			if child:IsA("LocalScript") then
				child:Destroy()
			end
		end

		if carsuitData.isEquipped then
			actionButton.Visible = false
		elseif carsuitData.isUnlocked then
			actionButton.Visible = false
		elseif carsuitData.unlockType == "Wins" then
			actionButton.Text = "BUY"
			actionButton.Visible = true
		elseif carsuitData.unlockType == "GamePass" or carsuitData.unlockType == "Robux" then
			actionButton.Text = "SEE IN SHOP"
			actionButton.Visible = true
		elseif carsuitData.unlockType == "Event" then
			actionButton.Text = "SEE INFO"
			actionButton.Visible = true
		else
			actionButton.Visible = false
		end

		-- Conectar evento de click al boton de accion
		actionButton.MouseButton1Click:Connect(function()
			OnCarsuitCardClicked(carsuitData)
		end)
	end

	-- Tambien hacer la card entera clickeable (para equipar rapido si esta desbloqueado)
	local cardButton = Instance.new("TextButton")
	cardButton.Name = "CardClickArea"
	cardButton.Size = UDim2.new(1, 0, 1, 0)
	cardButton.BackgroundTransparency = 1
	cardButton.Text = ""
	cardButton.ZIndex = 0  -- Detras del actionButton
	cardButton.Parent = card

	cardButton.MouseButton1Click:Connect(function()
		-- Solo equipar si ya esta desbloqueado (click en la card)
		if carsuitData.isUnlocked and not carsuitData.isEquipped then
			OnCarsuitCardClicked(carsuitData)
		end
	end)

	-- Aplicar opacidad si esta bloqueado
	if not carsuitData.isUnlocked then
		card.BackgroundTransparency = 0.5
	else
		card.BackgroundTransparency = 0
	end

	card.Parent = carScrollingFrame
	return card
end

-- Funcion para abrir el Shop (conectar luego)
local function OpenShop()
	print("[UI] Abriendo Shop...")
	-- TODO: Conectar con tu logica de Shop
	-- Ejemplo: shopFrame.Visible = true
end

-- Funcion para mostrar alerta de evento (conectar luego)
local function ShowEventAlert(carsuitData)
	print("[UI] Mostrando alerta de evento para carsuit " .. carsuitData.equipType)
	-- TODO: Conectar con tu sistema de alertas
	-- Ejemplo: alertFrame.Text = "Este carsuit se obtiene en: " .. (carsuitData.eventId or "Evento Especial")
	-- alertFrame.Visible = true
end

-- Handler cuando se hace click en una card
function OnCarsuitCardClicked(carsuitData)
	if carsuitData.isEquipped then
		-- Ya esta equipado, no hacer nada
		print("[UI] Ya tienes este carsuit equipado")
		return
	end

	if carsuitData.isUnlocked then
		-- Equipar
		print("[UI] Equipando carsuit " .. carsuitData.equipType)
		local result = equipCarsuit:InvokeServer(carsuitData.equipType)
		if result.success then
			RefreshUI()
		else
			warn("[UI] Error al equipar: " .. (result.message or "desconocido"))
		end
	else
		-- No esta desbloqueado, mostrar opciones segun tipo
		if carsuitData.unlockType == "Wins" then
			-- Intentar comprar con Wins
			print("[UI] Intentando comprar carsuit " .. carsuitData.equipType .. " por " .. carsuitData.cost .. " Wins")
			local result = unlockCarsuitWins:InvokeServer(carsuitData.equipType)
			if result.success then
				print("[UI] Carsuit desbloqueado!")
				RefreshUI()
			else
				warn("[UI] " .. (result.message or "No se pudo desbloquear"))
			end
		elseif carsuitData.unlockType == "GamePass" or carsuitData.unlockType == "Robux" then
			-- Abrir el Shop
			OpenShop()
		elseif carsuitData.unlockType == "Event" then
			-- Mostrar alerta de evento
			ShowEventAlert(carsuitData)
		end
	end
end

-- Refrescar la UI con datos del servidor
function RefreshUI()
	local data = getAllCarsuits:InvokeServer()

	if not data or not data.carsuits then
		warn("[CarsuitInventoryUI] No se pudieron obtener los carsuits")
		return
	end

	ClearCards()

	for _, carsuitData in ipairs(data.carsuits) do
		CreateCarsuitCard(carsuitData)
	end

	print("[CarsuitInventoryUI] UI actualizada con " .. #data.carsuits .. " carsuits")
end

-- Escuchar eventos del servidor
carsuitUnlocked.OnClientEvent:Connect(function(equipType)
	print("[UI] Carsuit " .. equipType .. " desbloqueado!")
	RefreshUI()
end)

carsuitEquipped.OnClientEvent:Connect(function(equipType)
	print("[UI] Carsuit " .. equipType .. " equipado!")
	RefreshUI()
end)

-- Refrescar cuando se abre el inventario
inventoryFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if inventoryFrame.Visible then
		RefreshUI()
	end
end)

-- Inicializar
task.defer(function()
	-- Esperar un poco para que el servidor este listo
	task.wait(1)
	RefreshUI()
end)

print("[CarsuitInventoryUI] Sistema inicializado")
