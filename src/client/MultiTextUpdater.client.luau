--[[
	═══════════════════════════════════════════════════════════════════════
	MULTI TEXT UPDATER
	═══════════════════════════════════════════════════════════════════════
	
	Este script actualiza el TextLabel "MultiText" en el ScreenGui
	para mostrar el multiplicador de rebirth actual del jugador.
	
	CONFIGURACIÓN REQUERIDA EN STARTERGUI:
	- ScreenGui > Frame "Buttons" > TextLabel "MultiText"
	
	═══════════════════════════════════════════════════════════════════════
]]

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Esperar a que el jugador esté listo
local playerGui = player:WaitForChild("PlayerGui")

-- Intentar encontrar el ScreenGui y el TextLabel
local buttons = playerGui:WaitForChild("Buttons", 10)
if not buttons then
	warn("[MultiTextUpdater] No se encontró 'Buttons' en PlayerGui")
	return
end

local multiText = buttons:WaitForChild("MultiText", 10)
if not multiText then
	warn("[MultiTextUpdater] No se encontró 'MultiText' en Buttons")
	return
end

-- Función para actualizar el texto del multiplicador
local function actualizarMultiText()
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	local rebirths = leaderstats:FindFirstChild("Rebirths")
	if not rebirths then return end
	
	-- Calcular el multiplicador según la fórmula: rebirths * 0.5 + 1
	local multiplicador = rebirths.Value * 0.5 + 1
	
	-- Actualizar el texto
	multiText.Text = string.format("%.1fx Multi (Rebirth)", multiplicador)
end

-- Actualizar cuando el jugador carga por primera vez
task.wait(1) -- Dar tiempo a que leaderstats se cree
actualizarMultiText()

-- Actualizar cuando cambian los rebirths
local leaderstats = player:WaitForChild("leaderstats")
local rebirths = leaderstats:WaitForChild("Rebirths")

rebirths:GetPropertyChangedSignal("Value"):Connect(function()
	actualizarMultiText()
end)

print("[MultiTextUpdater] ✅ Sistema de actualización del multiplicador activado")
