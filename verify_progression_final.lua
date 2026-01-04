-- Verificación de progresión final
-- Objetivo: Nivel 105 = 2.36M, Total acumulado = ~16M

local function getRequiredExp(level)
	local baseExp = 77 * (level ^ 2.2)
	local blockMultiplier = 1.0

	if level <= 25 then
		blockMultiplier = 1.0
	elseif level <= 50 then
		blockMultiplier = 1.05
	elseif level <= 125 then
		blockMultiplier = 1.10
	elseif level <= 175 then
		blockMultiplier = 1.20
	elseif level <= 275 then
		blockMultiplier = 1.35
	else
		blockMultiplier = 1.50
	end

	return math.floor(baseExp * blockMultiplier)
end

local function formatNumber(n)
	if n < 1000 then return tostring(math.floor(n)) end
	if n < 1000000 then return string.format("%.1fk", n/1000) end
	if n < 1000000000 then return string.format("%.2fM", n/1000000) end
	if n < 1000000000000 then return string.format("%.2fB", n/1000000000) end
	return string.format("%.2fT", n/1000000000000)
end

local function getCumulativeExp(targetLevel)
	local total = 0
	for level = 1, targetLevel - 1 do
		total = total + getRequiredExp(level)
	end
	return total
end

print("═════════════════════════════════════════════════════════════")
print("VERIFICACIÓN DE PROGRESIÓN - Fórmula: 25 × level^2.2")
print("═════════════════════════════════════════════════════════════")
print("")
print(string.format("%-8s %-15s %-20s %-15s", "Nivel", "EXP Requerida", "EXP Acumulada", "Block"))
print("─────────────────────────────────────────────────────────────")

local testLevels = {1, 5, 10, 15, 20, 25, 26, 30, 40, 50, 51, 60, 75, 90, 100, 105, 110, 125, 150, 175, 200, 250, 275, 300, 350, 375}

for _, level in ipairs(testLevels) do
	local expForLevel = getRequiredExp(level)
	local cumulativeExp = getCumulativeExp(level)

	local block = ""
	if level <= 25 then block = "Tutorial"
	elseif level <= 50 then block = "Early"
	elseif level <= 125 then block = "Mid-game"
	elseif level <= 175 then block = "First Wall"
	elseif level <= 275 then block = "Late-game"
	else block = "Endgame"
	end

	local marker = ""
	if level == 105 then
		marker = " ⭐ TARGET"
	elseif level == 25 or level == 50 or level == 75 or level == 125 or level == 175 or level == 275 or level == 375 then
		marker = " 🔄 Rebirth"
	end

	print(string.format("%-8d %-15s %-20s %-15s%s",
		level,
		formatNumber(expForLevel),
		formatNumber(cumulativeExp),
		block,
		marker
	))
end

print("")
print("═════════════════════════════════════════════════════════════")
print("VERIFICACIÓN DE OBJETIVOS:")
print("═════════════════════════════════════════════════════════════")

local exp105 = getRequiredExp(105)
local cumulative105 = getCumulativeExp(105)

print(string.format("✓ Nivel 105 → 106 requiere: %s", formatNumber(exp105)))
print(string.format("  (Objetivo: 2.36M) - Diferencia: %.1f%%", math.abs(exp105 - 2360000) / 2360000 * 100))
print("")
print(string.format("✓ EXP acumulada al nivel 105: %s", formatNumber(cumulative105)))
print(string.format("  (Objetivo: ~16M) - Diferencia: %.1f%%", math.abs(cumulative105 - 16000000) / 16000000 * 100))
print("")
print("═════════════════════════════════════════════════════════════")
print("ANÁLISIS DE REBIRTH:")
print("═════════════════════════════════════════════════════════════")

for rebirth = 0, 15 do
	local requiredLevel = 25 + (rebirth * 25)
	if requiredLevel > 375 then break end

	local cumulativeExp = getCumulativeExp(requiredLevel)
	print(string.format("Rebirth %2d → Nivel %3d | EXP Total: %s",
		rebirth,
		requiredLevel,
		formatNumber(cumulativeExp)
	))
end

print("")
print("═════════════════════════════════════════════════════════════")
