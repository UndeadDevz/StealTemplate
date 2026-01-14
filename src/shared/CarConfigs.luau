--[[
	═══════════════════════════════════════════════════════════════════════
	CAR CONFIGURATIONS - SISTEMA HÍBRIDO
	═══════════════════════════════════════════════════════════════════════

	Define la configuración de cada EquipType.

	Dos tipos de configuración:

	1. Type = "Texture": Cambio de textura UV instantáneo
	   - Aplica TextureID a todos los MeshParts del auto
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
	TextureID: string,  -- Asset ID de Roblox (ej: "rbxassetid://123456789")
}

export type ModelConfig = {
	Type: "Model",
	ModelName: string,
}

export type CarConfig = TextureConfig | ModelConfig

-- ═══════════════════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE EQUIPOS
-- ═══════════════════════════════════════════════════════════════════════

-- Modelo base por defecto (usado para Type = "Texture")
local DEFAULT_MODEL = "CocheMesh"
local DEFAULT_ALTURA = 0.8
local DEFAULT_ROTACION = 180

local CarConfigs: { [number]: CarConfig } = {
	[1] = {
		Type = "Texture",
		TextureID = "rbxassetid://82038652466798",
		ExpBase = 1,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
	},
	[2] = {
		Type = "Texture",
		TextureID = "rbxassetid://110790282037693",
		ExpBase = 2,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
	},
	[3] = {
		Type = "Texture",
		TextureID = "rbxassetid://126479336931992",
		ExpBase = 5,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
	},
	[4] = {
		Type = "Texture",
		TextureID = "rbxassetid://135047336608255",
		ExpBase = 25,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
	},
	[5] = {
		Type = "Texture",
		TextureID = "rbxassetid://117607448214663",
		ExpBase = 50,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
	},
	[6] = {
		Type = "Texture",
		TextureID = "rbxassetid://121164988345026",
		ExpBase = 100,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
	},
	[7] = {
		Type = "Texture",
		TextureID = "rbxassetid://95142104921853",
		ExpBase = 250,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
	},
	[8] = {
		Type = "Texture",
		TextureID = "rbxassetid://72542651954133",
		ExpBase = 500,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
	},
	[9] = {
		Type = "Model",
		ModelName = "SharkTruck",
		ExpBase = 50000,
		AlturaAuto = 4,
		Rotacion = 0,
	},
}

return CarConfigs
