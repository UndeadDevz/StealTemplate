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
	ExpBase: number,
	ModelName: string,
	AlturaAuto: number,
	Rotacion: number,
	WheelRotation: Vector3,
}

export type ModelConfig = {
	Type: "Model",
	ModelName: string,
	ExpBase: number,
	AlturaAuto: number,
	Rotacion: number,
	WheelRotation: Vector3,
}

export type CarConfig = TextureConfig | ModelConfig

-- ═══════════════════════════════════════════════════════════════════════
-- CONFIGURACIÓN DE EQUIPOS
-- ═══════════════════════════════════════════════════════════════════════

-- Modelo base por defecto (usado para Type = "Texture")
local DEFAULT_MODEL = "CocheMesh"
local DEFAULT_ALTURA = 0.8
local DEFAULT_ROTACION = 180
local DEFAULT_WHEEL_ROTATION = Vector3.new(0, 0, 0)

local CarConfigs: { [number]: CarConfig } = {
	[1] = {
		Type = "Texture",
		TextureID = "rbxassetid://82038652466798",
		ExpBase = 1,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
		WheelRotation = DEFAULT_WHEEL_ROTATION,
	},
	[2] = {
		Type = "Texture",
		TextureID = "rbxassetid://110790282037693",
		ExpBase = 2,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
		WheelRotation = DEFAULT_WHEEL_ROTATION,
	},
	[3] = {
		Type = "Texture",
		TextureID = "rbxassetid://126479336931992",
		ExpBase = 5,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
		WheelRotation = DEFAULT_WHEEL_ROTATION,
	},
	[4] = {
		Type = "Texture",
		TextureID = "rbxassetid://135047336608255",
		ExpBase = 25,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
		WheelRotation = DEFAULT_WHEEL_ROTATION,
	},
	[5] = {
		Type = "Texture",
		TextureID = "rbxassetid://117607448214663",
		ExpBase = 50,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
		WheelRotation = DEFAULT_WHEEL_ROTATION,
	},
	[6] = {
		Type = "Texture",
		TextureID = "rbxassetid://121164988345026",
		ExpBase = 100,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
		WheelRotation = DEFAULT_WHEEL_ROTATION,
	},
	[7] = {
		Type = "Texture",
		TextureID = "rbxassetid://95142104921853",
		ExpBase = 250,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
		WheelRotation = DEFAULT_WHEEL_ROTATION,
	},
	[8] = {
		Type = "Texture",
		TextureID = "rbxassetid://72542651954133",
		ExpBase = 500,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
		WheelRotation = DEFAULT_WHEEL_ROTATION,
	},
	[9] = {
		Type = "Model",
		ModelName = "SharkTruck",
		ExpBase = 50000,
		AlturaAuto = 4,
		Rotacion = 0,
		WheelRotation = Vector3.new(-90, -90, 0),
	},
	[10] = {
		Type = "Texture",
		TextureID = "rbxassetid://100494096447046",
		ExpBase = 500,
		ModelName = DEFAULT_MODEL,
		AlturaAuto = DEFAULT_ALTURA,
		Rotacion = DEFAULT_ROTACION,
		WheelRotation = DEFAULT_WHEEL_ROTATION,
	},
}

return CarConfigs
