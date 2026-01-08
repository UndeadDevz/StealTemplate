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

local CarConfigs: { [number]: CarConfig } = {
	-- EquipType 1: Textura por defecto (vacía o base)
	[1]= { 
		Type = "Texture",
		TextureID = "rbxassetid://82038652466798"
	},
	[2] = {
		Type = "Texture",
		TextureID = "rbxassetid://110790282037693",  -- Sin textura (usa el material base del modelo)
	},
	-- EquipType 2: Textura personalizada
	[3] = {
		Type = "Texture",
		TextureID = "rbxassetid://126479336931992",
	},

	-- EquipType 3: Otra textura
	[4] = {
		Type = "Texture",
		TextureID = "rbxassetid://135047336608255",  -- Cambia por tu asset ID
	},
	-- EquipType 4: Modelo completamente diferente
	[5] = {
		Type = "Texture",
		TextureID = "rbxassetid://117607448214663",  -- Cambia por tu asset ID
	},
		[6] = {
		Type = "Texture",
		TextureID = "rbxassetid://121164988345026",  -- Cambia por tu asset ID
	},
		[7] = {
		Type = "Texture",
		TextureID = "rbxassetid://95142104921853",  -- Cambia por tu asset ID
	},
		[8] = {
		Type = "Texture",
		TextureID = "rbxassetid://72542651954133",  -- Cambia por tu asset ID
	},
	
	

	-- Agrega más EquipTypes según necesites...
}

return CarConfigs
