--[[
	═══════════════════════════════════════════════════════════════════════
	REBIRTH BUTTON HANDLER
	═══════════════════════════════════════════════════════════════════════

	Busca automáticamente un botón llamado "RebirthButton" en StarterGui.
	Búsqueda recursiva - puede estar en cualquier nivel de anidamiento.

	Ubicación esperada: StarterGui > RebirthModal > Frame > ... > RebirthButton

	Rebirth Normal (Gratis):
	- Resetea nivel a 1
	- Resetea EXP a 0
	- Resetea velocidad a base

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local requestRebirth = remoteEvents:WaitForChild("RequestRebirth")

task.spawn(function()
	task.wait(2) -- Esperar a que la UI cargue

	-- Buscar el botón recursivamente en todos los ScreenGuis
	local rebirthButton = nil

	for _, gui in pairs(playerGui:GetChildren()) do
		if gui:IsA("ScreenGui") then
			-- Búsqueda recursiva (true = buscar en descendientes)
			local button = gui:FindFirstChild("RebirthButton", true)

			if button and (button:IsA("TextButton") or button:IsA("ImageButton")) then
				rebirthButton = button
				print("[RebirthButton] ✓ Botón encontrado:", button:GetFullName())
				break
			end
		end
	end

	if not rebirthButton then
		warn("[RebirthButton] No se encontró 'RebirthButton' en PlayerGui")
		return
	end

	-- Conectar evento de click
	rebirthButton.MouseButton1Click:Connect(function()
		requestRebirth:FireServer()
	end)
end)

print("[RebirthButton] ✅ Sistema inicializado")
