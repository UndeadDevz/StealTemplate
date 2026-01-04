-- Calcular el base correcto para lograr 2.36M en nivel 105
-- Formula: base × level^2.2 × blockMultiplier

local targetExp = 2360000  -- 2.36M
local level = 105
local blockMult = 1.10     -- Mid-game multiplier

-- Calcular level^2.2
local levelPower = level ^ 2.2
print("105^2.2 =", levelPower)

-- Calcular base necesario
local baseNeeded = targetExp / (levelPower * blockMult)
print("Base necesario:", baseNeeded)

-- Verificar
local result = baseNeeded * levelPower * blockMult
print("Verificación:", result, "(debe ser ~2.36M)")

-- Ahora calcular acumulado al nivel 105 con este base
local function getRequiredExp(lvl, base)
	local baseExp = base * (lvl ^ 2.2)
	local mult = 1.0
	if lvl <= 25 then mult = 1.0
	elseif lvl <= 50 then mult = 1.05
	elseif lvl <= 125 then mult = 1.10
	elseif lvl <= 175 then mult = 1.20
	elseif lvl <= 275 then mult = 1.35
	else mult = 1.50
	end
	return math.floor(baseExp * mult)
end

local cumulative = 0
for i = 1, 104 do
	cumulative = cumulative + getRequiredExp(i, baseNeeded)
end

print("\nEXP acumulada al nivel 105:", cumulative, string.format("(%.2fM)", cumulative/1000000))
print("Objetivo: ~16M")
print("Diferencia:", string.format("%.1f%%", math.abs(cumulative - 16000000) / 16000000 * 100))
