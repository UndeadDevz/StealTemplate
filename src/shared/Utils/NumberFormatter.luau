--[[
	NumberFormatter
	Centralized module for formatting large numbers with suffix notation

	Supports: k, M, B, T, Qa, Qi, Sx, Sp, Oc, No, Dc
	Example: 1,234,567,890 → "1.23B"
]]

local NumberFormatter = {}

-- Suffix definitions in order (thousands, millions, billions, etc.)
local SUFFIXES = {
	"",   -- 1-999
	"k",  -- Thousands (10^3)
	"M",  -- Millions (10^6)
	"B",  -- Billions (10^9)
	"T",  -- Trillions (10^12)
	"Qa", -- Quadrillions (10^15)
	"Qi", -- Quintillions (10^18)
	"Sx", -- Sextillions (10^21)
	"Sp", -- Septillions (10^24)
	"Oc", -- Octillions (10^27)
	"No", -- Nonillions (10^30)
	"Dc", -- Decillions (10^33)
}

--[[
	Formats a number with suffix notation

	@param n number - The number to format
	@param decimals number? - Number of decimal places (default: 1)
	@return string - Formatted number

	Examples:
		Format(500) → "500"
		Format(1500) → "1.5k"
		Format(1234567) → "1.23M"
		Format(6900000000000000) → "6.9Qa"
]]
function NumberFormatter.Format(n: number, decimals: number?): string
	decimals = decimals or 1

	-- Handle negative numbers
	local isNegative = n < 0
	n = math.abs(n)

	-- Numbers less than 1000 don't need suffixes
	if n < 1000 then
		return (isNegative and "-" or "") .. tostring(math.floor(n))
	end

	-- Find the appropriate suffix
	local index = 1
	while n >= 1000 and index < #SUFFIXES do
		n = n / 1000
		index = index + 1
	end

	-- Format the number with specified decimals
	local formatted = string.format("%." .. decimals .. "f%s", n, SUFFIXES[index])

	-- Remove trailing zeros after decimal point (e.g., "1.0k" → "1k")
	formatted = formatted:gsub("%.0+([a-zA-Z]+)$", "%1")

	return (isNegative and "-" or "") .. formatted
end

--[[
	Formats a number with commas for readability (no suffixes)

	@param n number - The number to format
	@return string - Formatted number with commas

	Examples:
		FormatWithCommas(1234567) → "1,234,567"
		FormatWithCommas(999) → "999"
]]
function NumberFormatter.FormatWithCommas(n: number): string
	local formatted = tostring(math.floor(n))

	-- Insert commas every 3 digits from the right
	local k
	while true do
		formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end

	return formatted
end

--[[
	Formats a number for display in progress bars (e.g., "123.45k / 500k")

	@param current number - Current value
	@param max number - Maximum value
	@param decimals number? - Number of decimal places (default: 1)
	@return string - Formatted progress string

	Examples:
		FormatProgress(1234, 5000) → "1.23k / 5k"
		FormatProgress(50, 100) → "50 / 100"
]]
function NumberFormatter.FormatProgress(current: number, max: number, decimals: number?): string
	return NumberFormatter.Format(current, decimals) .. " / " .. NumberFormatter.Format(max, decimals)
end

--[[
	Converts a formatted string back to a number (for parsing saved data)

	@param str string - Formatted number string (e.g., "1.5k", "6.9Qa")
	@return number - Parsed number value

	Examples:
		Parse("1.5k") → 1500
		Parse("6.9Qa") → 6900000000000000
		Parse("123") → 123
]]
function NumberFormatter.Parse(str: string): number
	-- Find suffix
	local numPart, suffix = str:match("^([%d%.%-]+)(%a*)$")
	if not numPart then return 0 end

	local num = tonumber(numPart) or 0

	-- Find multiplier based on suffix
	for i, sfx in ipairs(SUFFIXES) do
		if sfx == suffix then
			return num * (1000 ^ (i - 1))
		end
	end

	return num
end

return NumberFormatter
