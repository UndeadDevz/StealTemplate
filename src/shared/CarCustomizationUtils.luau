--[[
	═══════════════════════════════════════════════════════════════════════
	CAR CUSTOMIZATION UTILITIES
	═══════════════════════════════════════════════════════════════════════

	Funciones utilitarias para aplicar configuraciones de texturas/colores
	a coches existentes sin necesidad de reclonar el modelo completo.

	Funciones principales:
	- ApplyTextureConfig: Aplica colores/materiales a un coche existente
	- RequiresModelChange: Determina si un cambio requiere recarga completa
	- GetModelName: Obtiene el nombre del modelo base para un EquipType

	═══════════════════════════════════════════════════════════════════════
]]

local CarCustomizationUtils = {}

-- ═══════════════════════════════════════════════════════════════════════
-- FUNCIONES PRIVADAS
-- ═══════════════════════════════════════════════════════════════════════

-- Aplica propiedades a una parte con manejo de errores
local function applyProperties(part: BasePart, properties: { [string]: any })
	for propName, value in pairs(properties) do
		if value ~= nil then
			local success, err = pcall(function()
				part[propName] = value
			end)
			if not success then
				warn("[CarCustomization] Error aplicando " .. propName .. ": " .. err)
			end
		end
	end
end

-- ═══════════════════════════════════════════════════════════════════════
-- FUNCIONES PÚBLICAS
-- ═══════════════════════════════════════════════════════════════════════

--[[
	Aplica una configuración de textura a un coche existente

	@param coche Model - El modelo del coche a modificar
	@param config TextureConfig - La configuración a aplicar
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

	-- ═══════════════════════════════════════════════════════════════════
	-- 1. APLICAR A CARROCERÍA (Body)
	-- ═══════════════════════════════════════════════════════════════════
	local bodyModel = auto:FindFirstChild("Body")
	if bodyModel then
		for _, child in pairs(bodyModel:GetDescendants()) do
			if child:IsA("MeshPart") then
				local props = {}
				if config.BodyColor then
					props.Color = config.BodyColor
				end
				if config.BodyMaterial then
					props.Material = config.BodyMaterial
				end
				if config.BodyTransparency then
					props.Transparency = config.BodyTransparency
				end
				if config.BodyReflectance then
					props.Reflectance = config.BodyReflectance
				end
				applyProperties(child, props)

				-- TextureID requiere crear/modificar un objeto Texture
				if config.BodyTextureID then
					local texture = child:FindFirstChildOfClass("Texture")
					if not texture then
						texture = Instance.new("Texture")
						texture.Face = Enum.NormalId.Top
						texture.Parent = child
					end
					texture.Texture = config.BodyTextureID
				end
			end
		end
	end

	-- ═══════════════════════════════════════════════════════════════════
	-- 2. APLICAR A RUEDAS (Tires y Rims)
	-- ═══════════════════════════════════════════════════════════════════
	local tireModels = {
		auto:FindFirstChild("FrontLeftTire"),
		auto:FindFirstChild("FrontRightTire"),
		auto:FindFirstChild("BackRightTire"),
		auto:FindFirstChild("BackLelfTire"), -- Nota: tiene typo en el modelo original
	}

	for _, tireModel in ipairs(tireModels) do
		if tireModel then
			local wheelModel = tireModel:FindFirstChild("Wheel")
			if wheelModel then
				-- Aplicar a Tire (neumático)
				if config.TireColor or config.TireMaterial or config.TireTextureID then
					local tireSubModel = wheelModel:FindFirstChild("Tire")
					if tireSubModel then
						for _, meshPart in pairs(tireSubModel:GetDescendants()) do
							if meshPart:IsA("MeshPart") then
								local props = {}
								if config.TireColor then
									props.Color = config.TireColor
								end
								if config.TireMaterial then
									props.Material = config.TireMaterial
								end
								applyProperties(meshPart, props)

								if config.TireTextureID then
									local texture = meshPart:FindFirstChildOfClass("Texture")
									if not texture then
										texture = Instance.new("Texture")
										texture.Face = Enum.NormalId.Top
										texture.Parent = meshPart
									end
									texture.Texture = config.TireTextureID
								end
							end
						end
					end
				end

				-- Aplicar a Rim (rin/llanta)
				if config.RimColor or config.RimMaterial then
					local rimModel = wheelModel:FindFirstChild("Rim")
					if rimModel then
						for _, meshPart in pairs(rimModel:GetDescendants()) do
							if meshPart:IsA("MeshPart") then
								local props = {}
								if config.RimColor then
									props.Color = config.RimColor
								end
								if config.RimMaterial then
									props.Material = config.RimMaterial
								end
								applyProperties(meshPart, props)
							end
						end
					end
				end
			end
		end
	end

	-- ═══════════════════════════════════════════════════════════════════
	-- 3. APLICAR AL VOLANTE
	-- ═══════════════════════════════════════════════════════════════════
	local volante = coche:FindFirstChild("Volante", true) -- true = búsqueda recursiva
	if volante and volante:IsA("MeshPart") then
		local props = {}
		if config.SteeringWheelColor then
			props.Color = config.SteeringWheelColor
		end
		if config.SteeringWheelMaterial then
			props.Material = config.SteeringWheelMaterial
		end
		applyProperties(volante, props)
	end

	return true
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

	-- Si ambos son Texture, NO requiere recarga
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
