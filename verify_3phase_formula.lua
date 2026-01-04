-- Verificación de la fórmula de 3 fases
local function getRequiredExp(level)
	if level <= 25 then
		-- FASE 1: Tutorial (Lineal)
		return math.floor(51 + (level * 13))
	elseif level <= 50 then
		-- FASE 2A: Transición (Ratio 1.05)
		return math.floor(373 * (1.05 ^ (level - 25)))
	elseif level <= 75 then
		-- FASE 2B: Transición (Ratio 1.10)
		return math.floor(2120 * (1.10 ^ (level - 50)))
	else
		-- FASE 3: Exponencial (Ratio 1.15)
		return math.floor(35650 * (1.15 ^ (level - 75)))
	end
end

local function formatNumber(n)
	if n < 1000 then return tostring(math.floor(n)) end
	if n < 1000000 then return string.format("%.1fk", n/1000) end
	if n < 1000000000 then return string.format("%.2fM", n/1000000) end
	return string.format("%.2fB", n/1000000000)
end

print("═══════════════════════════════════════════════════════════════")
print("VERIFICACIÓN: Fórmula de 3 Fases")
print("═══════════════════════════════════════════════════════════════\n")

-- FASE 1: Tutorial (0-25) - Lineal
print("FASE 1: Tutorial (Niveles 0-25) - Crecimiento LINEAL")
print("Esperado: ~13 puntos por nivel\n")
print(string.format("%-10s %-15s %-20s %-15s", "Nivel", "EXP", "Especificación", "Match"))
print("───────────────────────────────────────────────────────────────")

local phase1Tests = {
	{level = 0, expected = 51},
	{level = 5, expected = 112},
	{level = 10, expected = 174},
	{level = 20, expected = 306},
	{level = 25, expected = 382}
}

for _, test in ipairs(phase1Tests) do
	local result = getRequiredExp(test.level)
	local diff = math.abs(result - test.expected)
	local match = diff <= 10 and "✓" or "✗"
	print(string.format("%-10d %-15s %-20d %s (diff: %d)",
		test.level, formatNumber(result), test.expected, match, diff))
end

-- FASE 2: Transición (26-75)
print("\n\nFASE 2: Transición (Niveles 26-75) - Ratio 1.05 → 1.10")
print("La curva empieza a empinarse\n")
print(string.format("%-10s %-15s %-20s %-15s", "Nivel", "EXP", "Especificación", "Match"))
print("───────────────────────────────────────────────────────────────")

local phase2Tests = {
	{level = 30, expected = 476},
	{level = 40, expected = 797},
	{level = 50, expected = 1730},
	{level = 60, expected = 5500},
	{level = 70, expected = 18700}
}

for _, test in ipairs(phase2Tests) do
	local result = getRequiredExp(test.level)
	local diff = math.abs(result - test.expected)
	local diffPercent = (diff / test.expected) * 100
	local match = diffPercent <= 10 and "✓" or "✗"
	print(string.format("%-10d %-15s %-20s %s (%.1f%%)",
		test.level, formatNumber(result), formatNumber(test.expected), match, diffPercent))
end

-- FASE 3: Muro Exponencial (76-100+)
print("\n\nFASE 3: Muro Exponencial (Niveles 76+) - Ratio 1.15")
print("Cada 5 niveles la EXP se DUPLICA\n")
print(string.format("%-10s %-15s %-20s %-15s", "Nivel", "EXP", "Especificación", "Match"))
print("───────────────────────────────────────────────────────────────")

local phase3Tests = {
	{level = 80, expected = 75800},
	{level = 88, expected = 220000},
	{level = 90, expected = 291000},
	{level = 95, expected = 585000},
	{level = 98, expected = 889000},
	{level = 99, expected = 1020000},
	{level = 100, expected = 1170000},
	{level = 105, expected = 2360000} -- ⭐ TARGET
}

for _, test in ipairs(phase3Tests) do
	local result = getRequiredExp(test.level)
	local diff = math.abs(result - test.expected)
	local diffPercent = (diff / test.expected) * 100
	local match = diffPercent <= 5 and "✓" or "✗"
	local marker = test.level == 105 and " ⭐ TARGET" or ""
	print(string.format("%-10d %-15s %-20s %s (%.1f%%)%s",
		test.level, formatNumber(result), formatNumber(test.expected), match, diffPercent, marker))
end

-- Verificar que se duplica cada 5 niveles
print("\n\nVERIFICACIÓN: ¿Se duplica cada 5 niveles?")
print("───────────────────────────────────────────────────────────────")
for level = 80, 100, 5 do
	local exp1 = getRequiredExp(level)
	local exp2 = getRequiredExp(level + 5)
	local ratio = exp2 / exp1
	print(string.format("Nivel %d → %d: %.2fx (esperado: ~2.0x)", level, level + 5, ratio))
end

print("\n═══════════════════════════════════════════════════════════════")
print("RESUMEN:")
print(string.format("  Nivel 105: %s (objetivo: 2.36M)", formatNumber(getRequiredExp(105))))
print(string.format("  Nivel 100: %s (objetivo: 1.17M)", formatNumber(getRequiredExp(100))))
print("═══════════════════════════════════════════════════════════════")
