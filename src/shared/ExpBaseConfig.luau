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
		-- Mid-Game (Costos suavizados)
    	[9] = { Value = 1000,   WinsCost = 80000 },
    	[10] = { Value = 1800,  WinsCost = 150000 },
    	[11] = { Value = 3200,  WinsCost = 300000 },
    	[12] = { Value = 6000,  WinsCost = 600000 },
    	[13] = { Value = 10000, WinsCost = 1200000 },
    
    -- Late-Game (Escala de Millones accesible)
    	[14] = { Value = 18000,  WinsCost = 2400000 },
    	[15] = { Value = 32000,  WinsCost = 4500000 },
    	[16] = { Value = 60000,  WinsCost = 9000000 },
    	[17] = { Value = 100000, WinsCost = 18000000 },
    
    -- Niveles Finales
    	[18] = { Value = 180000, WinsCost = 35000000 },
    	[19] = { Value = 320000, WinsCost = 70000000 },
    	[20] = { Value = 600000, WinsCost = 140000000 },
	},

	MaxLevel = 20,
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
