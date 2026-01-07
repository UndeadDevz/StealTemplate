--[[
	═══════════════════════════════════════════════════════════════════════
	REBIRTH STATS UPDATER
	═══════════════════════════════════════════════════════════════════════

	Este script actualiza los TextLabels que muestran las stats actuales
	y las stats después del próximo rebirth.

	CONFIGURACIÓN REQUERIDA EN STARTERGUI:
	- ScreenGui "Buttons" o donde estén estos labels:
	  * MaxLevelBefore: Muestra "Max Level X" actual
	  * MultiplierBefore: Muestra "Speed xY" actual
	  * MaxLevelAfter: Muestra "Max Level X" después del rebirth
	  * MultiplierAfter: Muestra "Speed xY" después del rebirth

	Solo se actualiza cuando cambia el Rebirth, no constantemente.

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Función para calcular el nivel máximo según rebirths
local function getMaxLevel(rebirths)
	local calculatedMax = 25 + (rebirths * 25)
	return math.min(calculatedMax, 375) -- Hard cap at 375
end

-- Función para calcular el multiplicador según rebirths
local function getMultiplier(rebirths)
	return rebirths * 0.5 + 1
end

-- Buscar los TextLabels (búsqueda recursiva en todos los ScreenGuis)
local maxLevelBefore = nil
local multiplierBefore = nil
local maxLevelAfter = nil
local multiplierAfter = nil

task.wait(2) -- Esperar a que la UI cargue

for _, gui in pairs(playerGui:GetChildren()) do
	if gui:IsA("ScreenGui") then
		if not maxLevelBefore then
			maxLevelBefore = gui:FindFirstChild("MaxLevelBefore", true)
		end
		if not multiplierBefore then
			multiplierBefore = gui:FindFirstChild("MultiplierBefore", true)
		end
		if not maxLevelAfter then
			maxLevelAfter = gui:FindFirstChild("MaxLevelAfter", true)
		end
		if not multiplierAfter then
			multiplierAfter = gui:FindFirstChild("MultiplierAfter", true)
		end
	end
end

-- Verificar que se encontraron todos los labels
if not maxLevelBefore then
	warn("[RebirthStatsUpdater] No se encontró 'MaxLevelBefore'")
end
if not multiplierBefore then
	warn("[RebirthStatsUpdater] No se encontró 'MultiplierBefore'")
end
if not maxLevelAfter then
	warn("[RebirthStatsUpdater] No se encontró 'MaxLevelAfter'")
end
if not multiplierAfter then
	warn("[RebirthStatsUpdater] No se encontró 'MultiplierAfter'")
end

-- Si no se encontró ninguno, salir
if not maxLevelBefore and not multiplierBefore and not maxLevelAfter and not multiplierAfter then
	warn("[RebirthStatsUpdater] No se encontraron labels de rebirth stats")
	return
end

-- Función para actualizar todos los labels
local function actualizarRebirthStats()
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end

	local rebirths = leaderstats:FindFirstChild("Rebirths")
	if not rebirths then return end

	local currentRebirths = rebirths.Value
	local nextRebirths = currentRebirths + 1

	-- Calcular stats actuales (BEFORE)
	local currentMaxLevel = getMaxLevel(currentRebirths)
	local currentMultiplier = getMultiplier(currentRebirths)

	-- Calcular stats del próximo rebirth (AFTER)
	local nextMaxLevel = getMaxLevel(nextRebirths)
	local nextMultiplier = getMultiplier(nextRebirths)

	-- Actualizar labels BEFORE
	if maxLevelBefore then
		maxLevelBefore.Text = "Max Level " .. currentMaxLevel
	end
	if multiplierBefore then
		multiplierBefore.Text = string.format("Speed x%.1f", currentMultiplier)
	end

	-- Actualizar labels AFTER
	if maxLevelAfter then
		maxLevelAfter.Text = "Max Level " .. nextMaxLevel
	end
	if multiplierAfter then
		multiplierAfter.Text = string.format("Speed x%.1f", nextMultiplier)
	end

	print("[RebirthStatsUpdater] Stats actualizadas - Rebirth " .. currentRebirths)
end

-- Esperar a que carguen los leaderstats
local leaderstats = player:WaitForChild("leaderstats")
local rebirths = leaderstats:WaitForChild("Rebirths")

-- Actualizar cuando cambia el rebirth
rebirths:GetPropertyChangedSignal("Value"):Connect(function()
	actualizarRebirthStats()
end)

-- Inicializar
task.wait(1)
actualizarRebirthStats()

print("[RebirthStatsUpdater] ✅ Sistema de actualización de Rebirth Stats activado")
