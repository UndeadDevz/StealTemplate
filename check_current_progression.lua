-- Quick check of current progression
local function getRatioForLevel(level)
	if level <= 25 then return 1.05
	elseif level <= 50 then return 1.10
	elseif level <= 125 then return 1.15
	elseif level <= 175 then return 1.20
	elseif level <= 275 then return 1.25
	else return 1.30
	end
end

local function getRequiredExp(level)
	local ratio = getRatioForLevel(level)
	return math.floor(51 * (ratio ^ level))
end

local function formatNumber(n)
	if n < 1000 then return tostring(n) end
	if n < 1000000 then return string.format("%.2fk", n/1000) end
	if n < 1000000000 then return string.format("%.2fM", n/1000000) end
	if n < 1000000000000 then return string.format("%.2fB", n/1000000000) end
	return string.format("%.2fT", n/1000000000000)
end

print("Current progression issues:")
print("Level 75: " .. formatNumber(getRequiredExp(75)))
print("Level 105: " .. formatNumber(getRequiredExp(105)))
print("Level 125: " .. formatNumber(getRequiredExp(125)))
print("\nThese numbers are astronomical!")
