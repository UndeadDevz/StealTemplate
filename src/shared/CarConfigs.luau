--[[
	═══════════════════════════════════════════════════════════════════════
	CAR CONFIGURATIONS - SISTEMA HÍBRIDO
	═══════════════════════════════════════════════════════════════════════

	Define la configuración de cada EquipType.

	Dos tipos de configuración:

	1. Type = "Texture": Cambios visuales instantáneos (colores, materiales, texturas)
	   - No requiere recargar personaje
	   - Cambio instantáneo

	2. Type = "Model": Modelo completamente diferente
	   - Requiere recargar personaje
	   - Usado para cambios de estructura/geometría

	═══════════════════════════════════════════════════════════════════════
]]

-- Tipos TypeScript-style para mejor documentación
export type TextureConfig = {
	Type: "Texture",

	-- Propiedades de la carrocería (Body)
	BodyColor: Color3?,
	BodyMaterial: Enum.Material?,
	BodyTextureID: string?,
	BodyTransparency: number?,
	BodyReflectance: number?,

	-- Propiedades de los neumáticos (Tire)
	TireColor: Color3?,
	TireMaterial: Enum.Material?,
	TireTextureID: string?,

	-- Propiedades de los rines (Rim)
	RimColor: Color3?,
	RimMaterial: Enum.Material?,

	-- Propiedades del volante
	SteeringWheelColor: Color3?,
	SteeringWheelMaterial: Enum.Material?,
}

export type ModelConfig = {
	Type: "Model",
	ModelName: string,
}

export type CarConfig = TextureConfig | ModelConfig

-- ═══════════════════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE EQUIPOS
-- ═══════════════════════════════════════════════════════════════════════

local CarConfigs: { [number]: CarConfig } = {
	-- EquipType 1: Coche rojo básico (Texture)
	[1] = {
		Type = "Texture",
		BodyColor = Color3.fromRGB(220, 50, 50),  -- Rojo
		BodyMaterial = Enum.Material.SmoothPlastic,
		TireColor = Color3.fromRGB(30, 30, 30),  -- Negro oscuro
		RimColor = Color3.fromRGB(180, 180, 180),  -- Gris plateado
		SteeringWheelColor = Color3.fromRGB(40, 40, 40),
	},

	[2] = {
		Type = "Texture",
		BodyTexture= "rbxassetid://126479336931992"
	},

	-- EquipType 3: Coche verde con materiales especiales (Texture)
	[3] = {
		Type = "Texture",
		BodyColor = Color3.fromRGB(50, 220, 50),  -- Verde brillante
		BodyMaterial = Enum.Material.Neon,  -- Material neón para efecto brillante
		TireColor = Color3.fromRGB(10, 10, 10),  -- Negro puro
		RimColor = Color3.fromRGB(255, 215, 0),  -- Dorado
		SteeringWheelColor = Color3.fromRGB(255, 215, 0),
	},

	-- EquipType 4: Coche azul metálico (Texture)
	[4] = {
		Type = "Texture",
		BodyColor = Color3.fromRGB(50, 100, 255),  -- Azul
		BodyMaterial = Enum.Material.Metal,
		BodyReflectance = 0.3,  -- Reflejo metálico
		TireColor = Color3.fromRGB(50, 50, 50),
		RimColor = Color3.fromRGB(200, 200, 255),  -- Azul claro
		SteeringWheelColor = Color3.fromRGB(20, 20, 20),
	},

	-- EquipType 5: Otro modelo diferente (Model)
	[5] = {
		Type = "Model",
		ModelName = "CocheMesh3",  -- Cambiar al nombre de tu modelo
	},

	-- Agrega más EquipTypes según necesites...
	-- Puedes mezclar tipos Texture y Model libremente
}

return CarConfigs
