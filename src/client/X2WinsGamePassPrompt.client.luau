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
	print("[X2WinsGamePassPrompt DEBUG] 📢 showX2WinsNotification llamada con baseWins:", baseWins)
	local doubledWins = baseWins * 2
	print("[X2WinsGamePassPrompt DEBUG] Calculado doubledWins:", doubledWins)

	-- Mostrar notificación de Roblox
	print("[X2WinsGamePassPrompt DEBUG] Intentando mostrar notificación...")
	local success, err = pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "💰 x2 Wins Available!",
			Text = string.format("Get %d wins instead of %d! Opening purchase prompt...", doubledWins, baseWins),
			Duration = 5,
			Icon = "rbxassetid://6031229361", -- Icono de monedas
		})
	end)

	if success then
		print("[X2WinsGamePassPrompt DEBUG] ✅ Notificación mostrada exitosamente")
	else
		warn("[X2WinsGamePassPrompt DEBUG] ❌ Error al mostrar notificación:", err)
	end

	print("[X2WinsGamePassPrompt] Notificación mostrada - Base:", baseWins, "Con x2:", doubledWins)

	-- Abrir prompt automáticamente después de 1 segundo
	print("[X2WinsGamePassPrompt DEBUG] Esperando 1 segundo antes de abrir prompt...")
	task.wait(1)
	print("[X2WinsGamePassPrompt DEBUG] Enviando FireServer para abrir prompt de compra")
	promptX2WinsPurchase:FireServer()
	print("[X2WinsGamePassPrompt DEBUG] FireServer enviado!")
end

-- Escuchar cuando el servidor envía la notificación
print("[X2WinsGamePassPrompt DEBUG] Conectando listener OnClientEvent...")
notifyX2WinsAvailable.OnClientEvent:Connect(function(baseWins)
	print("[X2WinsGamePassPrompt DEBUG] 🔔 OnClientEvent recibido! baseWins:", baseWins)
	showX2WinsNotification(baseWins)
end)
print("[X2WinsGamePassPrompt DEBUG] Listener conectado")

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
