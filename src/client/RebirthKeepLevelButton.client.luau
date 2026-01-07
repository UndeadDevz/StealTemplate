--[[
	═══════════════════════════════════════════════════════════════════════
	REBIRTH KEEP LEVEL BUTTON HANDLER
	═══════════════════════════════════════════════════════════════════════

	Busca automáticamente un botón llamado "RebirthKeepLevelButton" en StarterGui.
	Búsqueda recursiva - puede estar en cualquier nivel de anidamiento.

	Ubicación esperada: StarterGui > RebirthModal > Frame > ... > RebirthKeepLevelButton

	Rebirth Keep Level (Developer Product):
	- Requiere COMPRAR el producto cada vez
	- Mantiene nivel y EXP
	- Solo aumenta el contador de Rebirths

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local requestRebirthKeepLevel = remoteEvents:WaitForChild("RequestRebirthKeepLevel")

task.spawn(function()
	task.wait(2) -- Esperar a que la UI cargue

	-- Buscar el botón recursivamente en todos los ScreenGuis
	local rebirthButton = nil

	for _, gui in pairs(playerGui:GetChildren()) do
		if gui:IsA("ScreenGui") then
			-- Búsqueda recursiva (true = buscar en descendientes)
			local button = gui:FindFirstChild("RebirthKeepLevelButton", true)

			if button and (button:IsA("TextButton") or button:IsA("ImageButton")) then
				rebirthButton = button
				print("[RebirthKeepLevelButton] ✓ Botón encontrado:", button:GetFullName())
				break
			end
		end
	end

	if not rebirthButton then
		warn("[RebirthKeepLevelButton] No se encontró 'RebirthKeepLevelButton' en PlayerGui")
		return
	end

	-- Conectar evento de click
	rebirthButton.MouseButton1Click:Connect(function()
		requestRebirthKeepLevel:FireServer()
	end)
end)

print("[RebirthKeepLevelButton] ✅ Sistema inicializado")
