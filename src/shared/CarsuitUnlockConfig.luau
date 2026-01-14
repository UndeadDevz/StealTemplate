--[[
	Configuracion de desbloqueo de Carsuits
	Define como se desbloquea cada carsuit

	Tipos de desbloqueo:
	- "Free": Desbloqueado desde el inicio
	- "Wins": Se compra con victorias
	- "Event": Solo disponible durante eventos especiales
	- "Robux": Se compra con Robux (Developer Product)
	- "GamePass": Se desbloquea con un GamePass

	Los carsuits son puramente visuales, no afectan la EXP ganada.
]]

export type UnlockType = "Free" | "Wins" | "Event" | "Robux" | "GamePass"

export type CarsuitUnlockInfo = {
	UnlockType: UnlockType,
	Cost: number?, -- Wins o Robux (segun tipo)
	GamePassId: number?, -- Solo para tipo GamePass
	DevProductId: number?, -- Solo para tipo Robux
	EventId: string?, -- Solo para tipo Event
	DisplayName: string?, -- Nombre para mostrar en UI
}

local CarsuitUnlockConfig: { [number]: CarsuitUnlockInfo } = {
	[1] = {
		UnlockType = "Free",
		DisplayName = "Starter Car",
	},
	[2] = {
		UnlockType = "Wins",
		Cost = 5,
		DisplayName = "Racer",
	},
	[3] = {
		UnlockType = "Wins",
		Cost = 20,
		DisplayName = "Speedster",
	},
	[4] = {
		UnlockType = "Wins",
		Cost = 100,
		DisplayName = "Turbo",
	},
	[5] = {
		UnlockType = "Wins",
		Cost = 500,
		DisplayName = "Lightning",
	},
	[6] = {
		UnlockType = "Wins",
		Cost = 2500,
		DisplayName = "Thunder",
	},
	[7] = {
		UnlockType = "Wins",
		Cost = 12000,
		DisplayName = "Storm",
	},
	[8] = {
		UnlockType = "Wins",
		Cost = 50000,
		DisplayName = "Hurricane",
	},
	[9] = {
		UnlockType = "GamePass",
		GamePassId = 0, -- TODO: Reemplazar con el ID real del GamePass
		DisplayName = "SharkTruck",
	},
}

-- Obtener informacion de desbloqueo para un carsuit
function CarsuitUnlockConfig.GetUnlockInfo(equipType: number): CarsuitUnlockInfo?
	return CarsuitUnlockConfig[equipType]
end

-- Verificar si un carsuit puede ser comprado con Wins
function CarsuitUnlockConfig.CanUnlockWithWins(equipType: number, playerWins: number): boolean
	local info = CarsuitUnlockConfig[equipType]
	if not info then return false end

	if info.UnlockType == "Free" then
		return true
	elseif info.UnlockType == "Wins" then
		return playerWins >= (info.Cost or 0)
	end

	return false
end

-- Obtener el costo en Wins para desbloquear (nil si no es tipo Wins)
function CarsuitUnlockConfig.GetWinsCost(equipType: number): number?
	local info = CarsuitUnlockConfig[equipType]
	if info and info.UnlockType == "Wins" then
		return info.Cost
	end
	return nil
end

-- Obtener todos los EquipTypes disponibles (solo keys numericas)
function CarsuitUnlockConfig.GetAllEquipTypes(): { number }
	local types = {}
	for equipType, value in pairs(CarsuitUnlockConfig) do
		-- Solo incluir keys numericas (ignorar funciones)
		if type(equipType) == "number" and type(value) == "table" then
			table.insert(types, equipType)
		end
	end
	table.sort(types)
	return types
end

-- Obtener el total de carsuits configurados
function CarsuitUnlockConfig.GetTotalCarsuits(): number
	local count = 0
	for equipType, value in pairs(CarsuitUnlockConfig) do
		if type(equipType) == "number" and type(value) == "table" then
			count = count + 1
		end
	end
	return count
end

return CarsuitUnlockConfig
