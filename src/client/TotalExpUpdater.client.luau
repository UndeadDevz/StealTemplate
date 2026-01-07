--[[
	═══════════════════════════════════════════════════════════════════════
	TOTAL EXP UPDATER
	═══════════════════════════════════════════════════════════════════════

	Este script actualiza el TextLabel "TotalExp" en el ScreenGui "Buttons"
	para mostrar el TotalEXP del jugador en formato "27k Speed".

	CONFIGURACIÓN REQUERIDA EN STARTERGUI:
	- ScreenGui "Buttons" > TextLabel "TotalExp"

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Import NumberFormatter
local NumberFormatter = require(ReplicatedStorage:WaitForChild("Utils"):WaitForChild("NumberFormatter"))

-- Esperar RemoteFunction
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local getStat = remoteEvents:WaitForChild("GetStat")

-- Buscar el TextLabel
local buttons = playerGui:WaitForChild("Buttons", 10)
if not buttons then
	warn("[TotalExpUpdater] No se encontró 'Buttons' en PlayerGui")
	return
end

local totalExpText = buttons:WaitForChild("TotalExp", 10)
if not totalExpText then
	warn("[TotalExpUpdater] No se encontró 'TotalExp' en Buttons")
	return
end

-- Función para actualizar el texto
local function actualizarTotalExp()
	local totalExp = getStat:InvokeServer("TotalEXP")
	if totalExp then
		totalExpText.Text = NumberFormatter.Format(totalExp) .. " Speed"
	end
end

-- Actualizar cada 0.5 segundos
task.spawn(function()
	while task.wait(0.5) do
		actualizarTotalExp()
	end
end)

-- Inicializar
task.wait(1)
actualizarTotalExp()

print("[TotalExpUpdater] ✅ Sistema de actualización de TotalEXP activado")
