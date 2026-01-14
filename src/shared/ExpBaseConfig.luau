--[[
	Configuracion de niveles de ExpBase
	El jugador compra mejoras con Wins para aumentar su ExpBase

	Valores basados en los ExpBase originales de los coches
]]

local ExpBaseConfig = {
	-- Niveles de ExpBase (indice -> {Value, WinsCost})
	Levels = {
		[1] = { Value = 1,   WinsCost = 0 },      -- Gratis al iniciar
		[2] = { Value = 2,   WinsCost = 3 },
		[3] = { Value = 5,   WinsCost = 15 },
		[4] = { Value = 25,  WinsCost = 75 },
		[5] = { Value = 50,  WinsCost = 400 },
		[6] = { Value = 100, WinsCost = 2000 },
		[7] = { Value = 250, WinsCost = 10000 },
		[8] = { Value = 500, WinsCost = 40000 },
	},

	MaxLevel = 8,
}

-- Obtener el valor de ExpBase para un nivel dado
function ExpBaseConfig.GetExpBaseValue(level: number): number
	local config = ExpBaseConfig.Levels[level]
	return config and config.Value or 1
end

-- Obtener el costo en Wins para un nivel dado
function ExpBaseConfig.GetWinsCost(level: number): number
	local config = ExpBaseConfig.Levels[level]
	return config and config.WinsCost or 0
end

-- Obtener el siguiente nivel disponible para comprar
function ExpBaseConfig.GetNextLevel(currentLevel: number): number?
	if currentLevel >= ExpBaseConfig.MaxLevel then
		return nil
	end
	return currentLevel + 1
end

-- Verificar si un nivel es valido
function ExpBaseConfig.IsValidLevel(level: number): boolean
	return level >= 1 and level <= ExpBaseConfig.MaxLevel
end

return ExpBaseConfig
