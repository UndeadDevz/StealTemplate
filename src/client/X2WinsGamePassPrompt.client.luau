--[[
	═══════════════════════════════════════════════════════════════════════
	X2 WINS GAMEPASS PROMPT - Cliente
	═══════════════════════════════════════════════════════════════════════

	Este script:
	1. Muestra notificaciones cuando el jugador toca una zona sin el GamePass
	2. Maneja el botón de compra del GamePass (si existe en la UI)

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar a los RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local notifyX2WinsAvailable = remoteEvents:WaitForChild("NotifyX2WinsAvailable")
local promptX2WinsPurchase = remoteEvents:WaitForChild("PromptX2WinsPurchase")

-- Función para mostrar notificación con opción de compra
local function showX2WinsNotification(baseWins)
	local doubledWins = baseWins * 2

	-- Mostrar notificación de Roblox
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "💰 x2 Wins Available!",
			Text = string.format("Get %d wins instead of %d! Tap to buy GamePass.", doubledWins, baseWins),
			Duration = 8,
			Icon = "rbxassetid://6031229361", -- Icono de monedas
			Button1 = "Buy Now!",
			Callback = function()
				-- Cuando presionan el botón, pedir al servidor que abra el prompt
				promptX2WinsPurchase:FireServer()
			end
		})
	end)

	print("[X2WinsGamePassPrompt] Notificación mostrada - Base:", baseWins, "Con x2:", doubledWins)
end

-- Escuchar cuando el servidor envía la notificación
notifyX2WinsAvailable.OnClientEvent:Connect(function(baseWins)
	showX2WinsNotification(baseWins)
end)

-- Buscar botón UI para comprar GamePass (OPCIONAL)
-- Si tienes un botón en tu UI llamado "X2WinsButton", lo conecta automáticamente
task.spawn(function()
	task.wait(2) -- Esperar a que la UI cargue

	-- Buscar en todos los ScreenGuis
	for _, gui in pairs(playerGui:GetChildren()) do
		if gui:IsA("ScreenGui") then
			-- Buscar botón recursivamente
			local button = gui:FindFirstChild("X2WinsButton", true)

			if button and button:IsA("GuiButton") then
				print("[X2WinsGamePassPrompt] ✓ Botón x2 Wins encontrado:", button:GetFullName())

				button.MouseButton1Click:Connect(function()
					-- Pedir al servidor que abra el prompt de compra
					promptX2WinsPurchase:FireServer()
					print("[X2WinsGamePassPrompt] Jugador presionó botón de compra")
				end)

				break
			end
		end
	end
end)

print("[X2WinsGamePassPrompt] ✓ Sistema inicializado")
