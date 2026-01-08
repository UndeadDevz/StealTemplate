--[[
	═══════════════════════════════════════════════════════════════════════
	CAR CUSTOMIZATION UTILITIES
	═══════════════════════════════════════════════════════════════════════

	Funciones utilitarias para aplicar texturas UV a coches existentes
	sin necesidad de reclonar el modelo completo.

	Funciones principales:
	- ApplyTextureConfig: Aplica TextureID a todos los MeshParts del auto
	- RequiresModelChange: Determina si un cambio requiere recarga completa
	- GetModelName: Obtiene el nombre del modelo base para un EquipType

	═══════════════════════════════════════════════════════════════════════
]]

local CarCustomizationUtils = {}

-- ═══════════════════════════════════════════════════════════════════════
-- FUNCIONES PÚBLICAS
-- ═══════════════════════════════════════════════════════════════════════

--[[
	Aplica una configuración de textura UV a todos los MeshParts de un coche

	IMPORTANTE: Este método aplica el TextureID directamente a las propiedades
	TextureContent y TextureID del MeshPart, NO crea objetos Texture hijos.

	@param coche Model - El modelo del coche a modificar
	@param config TextureConfig - La configuración a aplicar (debe tener Type="Texture")
	@return boolean - true si se aplicó exitosamente, false si hubo errores
]]
function CarCustomizationUtils.ApplyTextureConfig(coche: Model, config: any): boolean
	if not coche or not coche:IsA("Model") then
		warn("[CarCustomization] Coche inválido")
		return false
	end

	if not config or config.Type ~= "Texture" then
		warn("[CarCustomization] Config no es de tipo Texture")
		return false
	end

	local auto = coche:FindFirstChild("auto")
	if not auto then
		warn("[CarCustomization] No se encontró 'auto' en el coche")
		return false
	end

	local textureID = config.TextureID or ""
	local aplicados = 0

	-- ═══════════════════════════════════════════════════════════════════
	-- APLICAR TEXTURA A TODOS LOS MESHPARTS DENTRO DE AUTO
	-- ═══════════════════════════════════════════════════════════════════
	-- Búsqueda recursiva para encontrar TODOS los MeshParts
	-- Esto es necesario porque el modelo usa un UV map compartido
	for _, descendant in pairs(auto:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			-- Aplicar TextureID directamente a las propiedades del MeshPart
			local success, err = pcall(function()
				descendant.TextureID = textureID
			end)

			if success then
				aplicados = aplicados + 1
			else
				warn("[CarCustomization] Error aplicando textura a " .. descendant.Name .. ": " .. tostring(err))
			end
		end
	end

	if aplicados > 0 then
		print("[CarCustomization] ✓ Textura aplicada a " .. aplicados .. " MeshParts")
		return true
	else
		warn("[CarCustomization] ⚠ No se aplicó textura a ningún MeshPart")
		return false
	end
end

--[[
	Determina si un cambio de EquipType requiere recarga completa del modelo

	@param oldEquipType number - EquipType actual
	@param newEquipType number - Nuevo EquipType
	@param configs table - Tabla de configuraciones (CarConfigs)
	@return boolean - true si requiere recarga, false si solo texturas
]]
function CarCustomizationUtils.RequiresModelChange(
	oldEquipType: number,
	newEquipType: number,
	configs: any
): boolean
	local oldConfig = configs[oldEquipType]
	local newConfig = configs[newEquipType]

	-- Si no hay configs, asumir que requiere cambio por seguridad
	if not oldConfig or not newConfig then
		return true
	end

	-- Si el tipo cambió (Texture <-> Model), requiere recarga
	if oldConfig.Type ~= newConfig.Type then
		return true
	end

	-- Si ambos son Model, verificar si el nombre cambió
	if newConfig.Type == "Model" then
		return oldConfig.ModelName ~= newConfig.ModelName
	end

	-- Si ambos son Texture, NO requiere recarga (cambio instantáneo)
	return false
end

--[[
	Obtiene el nombre del modelo base para un EquipType

	@param equipType number - El EquipType
	@param configs table - Tabla de configuraciones (CarConfigs)
	@return string - Nombre del modelo en ReplicatedStorage
]]
function CarCustomizationUtils.GetModelName(equipType: number, configs: any): string
	local config = configs[equipType]
	if not config then
		return "CocheMesh" -- Default
	end

	if config.Type == "Model" then
		return config.ModelName
	else
		-- Para configs de textura, siempre usar el modelo base
		return "CocheMesh"
	end
end

return CarCustomizationUtils
