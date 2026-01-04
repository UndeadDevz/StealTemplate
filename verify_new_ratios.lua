-- Verificación de nuevos ratios
local function getRatioForLevel(level)
	if level <= 25 then return 1.018
	elseif level <= 50 then return 1.022
	elseif level <= 125 then return 1.026
	elseif level <= 175 then return 1.030
	elseif level <= 275 then return 1.034
	else return 1.038
	end
end

local function getRequiredExp(level)
	local ratio = getRatioForLevel(level)
	return math.floor(51 * (ratio ^ level))
end

local function formatNumber(n)
	if n < 1000 then return tostring(math.floor(n)) end
	if n < 1000000 then return string.format("%.1fk", n/1000) end
	if n < 1000000000 then return string.format("%.2fM", n/1000000) end
	if n < 1000000000000 then return string.format("%.2fB", n/1000000000) end
	return string.format("%.2fT", n/1000000000000)
end

print("═══════════════════════════════════════════════")
print("NUEVA PROGRESIÓN (Ratios Ajustados)")
print("═══════════════════════════════════════════════")
print(string.format("%-8s %-10s %-15s", "Nivel", "Ratio", "EXP Requerida"))
print("───────────────────────────────────────────────")

local testLevels = {1, 10, 25, 26, 50, 51, 75, 100, 105, 125, 150, 175, 200, 250, 275, 300, 350, 375}

for _, level in ipairs(testLevels) do
	local ratio = getRatioForLevel(level)
	local exp = getRequiredExp(level)
	print(string.format("%-8d %-10s %-15s", level, ratio, formatNumber(exp)))
end

print("\n═══════════════════════════════════════════════")
print("Comparación Clave:")
print("Nivel 75:  " .. formatNumber(getRequiredExp(75)))
print("Nivel 105: " .. formatNumber(getRequiredExp(105)))
print("Nivel 125: " .. formatNumber(getRequiredExp(125)))
print("═══════════════════════════════════════════════")
