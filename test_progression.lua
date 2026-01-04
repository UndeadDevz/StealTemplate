--[[
	Progression Curve Test Script
	Run this with: lua test_progression.lua

	This script calculates and displays the EXP required at key breakpoints
	to verify the progression curve is balanced correctly.
]]

-- Ratio lookup function
local function getRatioForLevel(level)
	if level <= 25 then return 1.05
	elseif level <= 50 then return 1.10
	elseif level <= 125 then return 1.15
	elseif level <= 175 then return 1.20
	elseif level <= 275 then return 1.25
	else return 1.30  -- 276+
	end
end

-- EXP required calculation
local function getRequiredExp(level)
	local ratio = getRatioForLevel(level)
	return math.floor(51 * (ratio ^ level))
end

-- Number formatter (simplified)
local function formatNumber(n)
	if n < 1000 then return tostring(math.floor(n)) end

	local suffixes = {"", "k", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}
	local index = 1

	while n >= 1000 and index < #suffixes do
		n = n / 1000
		index = index + 1
	end

	local formatted = string.format("%.2f%s", n, suffixes[index])
	return formatted:gsub("%.00", "")
end

-- Calculate cumulative EXP needed to reach a level
local function getCumulativeExp(targetLevel)
	local total = 0
	for level = 1, targetLevel - 1 do
		total = total + getRequiredExp(level)
	end
	return total
end

-- Test data
local testLevels = {1, 5, 10, 15, 20, 25, 26, 30, 40, 50, 51, 75, 100, 125, 126, 150, 175, 176, 200, 250, 275, 276, 300, 350, 375}

print("═══════════════════════════════════════════════════════════════════")
print("PROGRESSION CURVE TEST - EXP Requirements")
print("═══════════════════════════════════════════════════════════════════")
print("")
print(string.format("%-10s %-10s %-20s %-20s %-15s", "Level", "Ratio", "EXP for Level", "Cumulative EXP", "Block"))
print("───────────────────────────────────────────────────────────────────")

for _, level in ipairs(testLevels) do
	local ratio = getRatioForLevel(level)
	local expForLevel = getRequiredExp(level)
	local cumulativeExp = getCumulativeExp(level)

	local block = ""
	if level <= 25 then
		block = "Block 1"
	elseif level <= 50 then
		block = "Block 2"
	elseif level <= 125 then
		block = "Block 3"
	elseif level <= 175 then
		block = "Block 4"
	elseif level <= 275 then
		block = "Block 5"
	else
		block = "Block 6"
	end

	print(string.format("%-10d %-10s %-20s %-20s %-15s",
		level,
		ratio,
		formatNumber(expForLevel),
		formatNumber(cumulativeExp),
		block
	))
end

print("")
print("═══════════════════════════════════════════════════════════════════")
print("REBIRTH REQUIREMENTS")
print("═══════════════════════════════════════════════════════════════════")
print("")

for rebirth = 0, 15 do
	local requiredLevel = 25 + (rebirth * 25)
	if requiredLevel > 375 then break end

	local cumulativeExp = getCumulativeExp(requiredLevel)
	print(string.format("Rebirth %2d → Requires Level %3d | Total EXP needed: %s",
		rebirth,
		requiredLevel,
		formatNumber(cumulativeExp)
	))
end

print("")
print("═══════════════════════════════════════════════════════════════════")
print("MULTIPLIER IMPACT EXAMPLE")
print("═══════════════════════════════════════════════════════════════════")
print("")
print("Base EXP gain: 100 (EquipType 1, Zone 1x)")
print("Formula: (Base × Zone × Rebirth) × (1 + SpeedBoost)")
print("")

local baseExp = 100
for rebirth = 0, 10, 2 do
	local rebirthMult = rebirth * 0.5 + 1
	local baseValue = baseExp * rebirthMult

	print(string.format("Rebirth %d (%.1fx):", rebirth, rebirthMult))

	-- Test different speed multipliers
	for _, speedMult in ipairs({1, 2, 4, 8, 16}) do
		local speedBoost = speedMult - 1
		local finalExp = baseValue * (1 + speedBoost)
		print(string.format("  + Speed %2dx → EXP/tick: %8.0f (Total multiplier: %.1fx)", speedMult, finalExp, finalExp / baseExp))
	end
	print("")
end

print("═══════════════════════════════════════════════════════════════════")
