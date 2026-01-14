-- LocalScript "CarSuit" en StarterCharacterScripts
--[[
	═══════════════════════════════════════════════════════════════════════
	CAR SUIT SYSTEM - REFACTORIZADO PARA CAMBIO DINÁMICO
	═══════════════════════════════════════════════════════════════════════

	Permite cambiar el modelo del coche sin recargar el personaje.
	Exporta:
	- _G.ChangeCarTextures(newEquipType) → Cambio de texturas instantáneo
	- _G.ChangeCarModel(newEquipType) → Cambio de modelo completo sin reload

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Importar módulos del sistema híbrido
local Shared = ReplicatedStorage:WaitForChild("Shared")
local CarConfigs = require(Shared:WaitForChild("CarConfigs"))
local CarCustomizationUtils = require(Shared:WaitForChild("CarCustomizationUtils"))

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid", 5)
local rootPart = character:WaitForChild("HumanoidRootPart", 5)
local lowerTorso = character:WaitForChild("LowerTorso", 5)

-- ═══════════════════════════════════════════════════════════════════════
-- ESTADO GLOBAL DEL COCHE
-- ═══════════════════════════════════════════════════════════════════════
local estadoCoche = {
	coche = nil,              -- Modelo del coche actual
	carroceria = nil,         -- MeshPart principal
	conductor = nil,          -- Modelo del conductor
	conductorAnimator = nil,  -- Animator del conductor
	equipTypeActual = nil,    -- EquipType actual

	-- Animaciones
	trackIdle = nil,
	trackLeft = nil,
	trackRight = nil,
	animActual = "idle",

	-- Motores de ruedas
	motoresRuedasDelanteras = {},
	motoresRuedasTraseras = {},
	anguloRotacionRueda = 0,

	-- Parámetros dinámicos
	offsetY = 0,
	rotacionY = 180,

	-- Conexiones
	renderConnection = nil,

	-- Raycast
	pitchActual = 0,
}

-- Animaciones
local ANIM_IDLE = "rbxassetid://94863045736134"
local ANIM_LEFT = "rbxassetid://102025087016232"
local ANIM_RIGHT = "rbxassetid://99169459312919"

-- Configuración del Raycast para rampas
local RAYCAST_DISTANCIA = 10
local VELOCIDAD_INCLINACION = 8
local PITCH_MAXIMO = math.rad(35)

-- Configuración de ruedas
local RADIO_RUEDA = 1

-- Control de input (compartido entre setups)
local teclas = {
	izquierda = false,
	derecha = false
}

-- Raycast params (compartido)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- ═══════════════════════════════════════════════════════════════════════
-- OBTENER EQUIPTYPE INICIAL
-- ═══════════════════════════════════════════════════════════════════════
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local getStatRemote = remoteEvents:WaitForChild("GetStat")

local function getInitialEquipType()
	local attrValue = player:GetAttribute("EquipType")

	if not attrValue then
		local waited = 0
		while not attrValue and waited < 3 do
			task.wait(0.1)
			waited = waited + 0.1
			attrValue = player:GetAttribute("EquipType")
		end
	end

	if attrValue then
		return attrValue
	end

	local success, result = pcall(function()
		return getStatRemote:InvokeServer("EquipType")
	end)

	if success and result then
		return result
	end
	return 1
end

-- ═══════════════════════════════════════════════════════════════════════
-- OCULTAR PERSONAJE REAL (solo se hace una vez)
-- ═══════════════════════════════════════════════════════════════════════
local function ocultarPersonajeReal()
	for _, parte in pairs(character:GetDescendants()) do
		if parte:IsA("BasePart") and parte.Name ~= "HumanoidRootPart" then
			parte.Transparency = 1
		elseif parte:IsA("Decal") then
			parte.Transparency = 1
		elseif parte:IsA("Texture") then
			parte.Transparency = 1
		elseif parte:IsA("SpecialMesh") then
			parte.Scale = Vector3.new(0, 0, 0)
		elseif parte:IsA("Accessory") then
			local handle = parte:FindFirstChild("Handle")
			if handle then
				handle.Transparency = 1
			end
		end
	end

	local head = character:FindFirstChild("Head")
	if head then
		local face = head:FindFirstChild("face") or head:FindFirstChild("Face")
		if face and face:IsA("Decal") then
			face.Transparency = 1
		end
	end

	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
			descendant.Transparency = 1
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = 1
		elseif descendant:IsA("SpecialMesh") then
			descendant.Scale = Vector3.new(0, 0, 0)
		elseif descendant:IsA("Accessory") then
			local handle = descendant:FindFirstChild("Handle")
			if handle then
				handle.Transparency = 1
			end
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- FUNCIONES AUXILIARES PARA SETUP DE RUEDAS
-- ═══════════════════════════════════════════════════════════════════════
local function estaEnModeloWheel(parte, auto)
	local parent = parte.Parent
	while parent and parent ~= auto do
		if parent:IsA("Model") and parent.Name == "Wheel" then
			return true
		end
		parent = parent.Parent
	end
	return false
end

local function encontrarMeshPartRueda(tireModel)
	if not tireModel then return nil end

	local wheelModel = tireModel:FindFirstChild("Wheel")
	if not wheelModel then
		warn("[CarSuit] ⚠ No se encontró modelo 'Wheel' dentro de " .. tireModel.Name)
		return nil
	end

	local tireSubModel = wheelModel:FindFirstChild("Tire")
	if tireSubModel then
		for _, desc in pairs(tireSubModel:GetDescendants()) do
			if desc:IsA("MeshPart") then
				return desc
			end
		end
	end

	local rimModel = wheelModel:FindFirstChild("Rim")
	if rimModel then
		for _, desc in pairs(rimModel:GetDescendants()) do
			if desc:IsA("MeshPart") then
				return desc
			end
		end
	end

	for _, desc in pairs(wheelModel:GetDescendants()) do
		if desc:IsA("MeshPart") then
			return desc
		end
	end

	return nil
end

local function soldarPartesWheel(wheelModel, ruedaPrincipal)
	for _, parte in pairs(wheelModel:GetDescendants()) do
		if parte:IsA("BasePart") and parte ~= ruedaPrincipal then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = ruedaPrincipal
			weld.Part1 = parte
			weld.Parent = ruedaPrincipal
		end
	end
end

local function crearMotorRueda(tireModel, carroceria, nombreRueda)
	local ruedaMesh = encontrarMeshPartRueda(tireModel)
	if not ruedaMesh then
		warn("[CarSuit] ❌ No se encontró MeshPart en " .. nombreRueda)
		return nil
	end

	local wheelModel = tireModel:FindFirstChild("Wheel")
	if wheelModel then
		soldarPartesWheel(wheelModel, ruedaMesh)
	end

	local offset = carroceria.CFrame:ToObjectSpace(ruedaMesh.CFrame)
	local motor = Instance.new("Motor6D")
	motor.Name = "Motor_" .. nombreRueda
	motor.Part0 = carroceria
	motor.Part1 = ruedaMesh
	motor.C0 = offset
	motor.Parent = carroceria

	return motor
end

-- ═══════════════════════════════════════════════════════════════════════
-- DESTRUIR COCHE ACTUAL
-- ═══════════════════════════════════════════════════════════════════════
local function destruirCocheActual()
	-- Desconectar RenderStepped
	if estadoCoche.renderConnection then
		estadoCoche.renderConnection:Disconnect()
		estadoCoche.renderConnection = nil
	end

	-- Parar animaciones
	if estadoCoche.trackIdle then estadoCoche.trackIdle:Stop() end
	if estadoCoche.trackLeft then estadoCoche.trackLeft:Stop() end
	if estadoCoche.trackRight then estadoCoche.trackRight:Stop() end

	-- Destruir el modelo del coche
	if estadoCoche.coche and estadoCoche.coche.Parent then
		estadoCoche.coche:Destroy()
	end

	-- Limpiar referencias
	estadoCoche.coche = nil
	estadoCoche.carroceria = nil
	estadoCoche.conductor = nil
	estadoCoche.conductorAnimator = nil
	estadoCoche.trackIdle = nil
	estadoCoche.trackLeft = nil
	estadoCoche.trackRight = nil
	estadoCoche.motoresRuedasDelanteras = {}
	estadoCoche.motoresRuedasTraseras = {}
	estadoCoche.anguloRotacionRueda = 0
	estadoCoche.pitchActual = 0
	estadoCoche.animActual = "idle"

	print("[CarSuit] ✓ Coche anterior destruido")
end

-- ═══════════════════════════════════════════════════════════════════════
-- SETUP DEL COCHE (función reutilizable)
-- ═══════════════════════════════════════════════════════════════════════
local function setupCoche(equipType)
	-- Obtener configuración
	local config = CarConfigs[equipType]
	if not config then
		warn("[CarSuit] ❌ No existe configuración para EquipType " .. equipType)
		return false
	end

	local nombreCoche = config.ModelName
	local alturaAuto = config.AlturaAuto or 0.8
	local rotacionY = config.Rotacion or 180

	-- Calcular offset de altura
	estadoCoche.offsetY = -humanoid.HipHeight + (lowerTorso.Size.Y / 2) + alturaAuto
	estadoCoche.rotacionY = rotacionY
	estadoCoche.equipTypeActual = equipType

	-- Clonar coche
	local cocheOriginal = ReplicatedStorage:FindFirstChild(nombreCoche)
	if not cocheOriginal then
		warn("[CarSuit] ❌ No se encontró el modelo '" .. nombreCoche .. "' en ReplicatedStorage")
		return false
	end

	local coche = cocheOriginal:Clone()
	coche.Parent = workspace
	estadoCoche.coche = coche

	-- Configurar partes del coche
	local auto = coche:FindFirstChild("auto")
	if not auto then
		warn("[CarSuit] ❌ No se encontró 'auto' en el coche!")
		coche:Destroy()
		return false
	end

	-- Buscar Body y carrocería
	local bodyModel = auto:FindFirstChild("Body")
	if not bodyModel then
		warn("[CarSuit] ❌ No se encontró 'Body' dentro de auto!")
		coche:Destroy()
		return false
	end

	local carroceria = nil
	for _, child in pairs(bodyModel:GetDescendants()) do
		if child:IsA("MeshPart") then
			carroceria = child
			break
		end
	end

	if not carroceria then
		warn("[CarSuit] ❌ No se encontró MeshPart dentro de Body!")
		coche:Destroy()
		return false
	end

	estadoCoche.carroceria = carroceria

	-- Buscar conductor
	local conductor = coche:FindFirstChild("Conductor")
	if not conductor then
		warn("[CarSuit] ❌ No se encontró 'Conductor' en el coche!")
		coche:Destroy()
		return false
	end

	conductor.Name = player.Name
	estadoCoche.conductor = conductor

	local conductorHumanoid = conductor:WaitForChild("Humanoid")
	conductorHumanoid.PlatformStand = true
	local conductorAnimator = conductorHumanoid:WaitForChild("Animator")
	estadoCoche.conductorAnimator = conductorAnimator

	-- Configurar partes como no colisionables
	for _, parte in pairs(coche:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.CanCollide = false
		end
	end

	-- Anclar carrocería
	carroceria.Anchored = true

	-- Obtener ruedas
	local frontLeftTire = auto:FindFirstChild("FrontLeftTire")
	local frontRightTire = auto:FindFirstChild("FrontRightTire")
	local backRightTire = auto:FindFirstChild("BackRightTire")
	local backLeftTire = auto:FindFirstChild("BackLelfTire")

	-- Soldar partes que NO son ruedas
	for _, parte in pairs(auto:GetDescendants()) do
		if parte:IsA("BasePart") and parte ~= carroceria then
			if not estaEnModeloWheel(parte, auto) then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = carroceria
				weld.Part1 = parte
				weld.Parent = carroceria
			end
		end
	end

	-- Configurar motores de ruedas
	estadoCoche.motoresRuedasDelanteras = {}
	estadoCoche.motoresRuedasTraseras = {}

	if frontLeftTire then
		local motor = crearMotorRueda(frontLeftTire, carroceria, "FrontLeftTire")
		if motor then
			table.insert(estadoCoche.motoresRuedasDelanteras, {motor = motor, offset = motor.C0})
		end
	end

	if frontRightTire then
		local motor = crearMotorRueda(frontRightTire, carroceria, "FrontRightTire")
		if motor then
			table.insert(estadoCoche.motoresRuedasDelanteras, {motor = motor, offset = motor.C0})
		end
	end

	if backRightTire then
		local motor = crearMotorRueda(backRightTire, carroceria, "BackRightTire")
		if motor then
			table.insert(estadoCoche.motoresRuedasTraseras, {motor = motor, offset = motor.C0})
		end
	end

	if backLeftTire then
		local motor = crearMotorRueda(backLeftTire, carroceria, "BackLeftTire")
		if motor then
			table.insert(estadoCoche.motoresRuedasTraseras, {motor = motor, offset = motor.C0})
		end
	end

	-- Soldar conductor a carrocería
	for _, parte in pairs(conductor:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.CanCollide = false
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = carroceria
			weld.Part1 = parte
			weld.Parent = carroceria
		end
	end

	conductor.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
		end
	end)

	-- Aplicar texturas si es tipo Texture
	if config.Type == "Texture" then
		local success = CarCustomizationUtils.ApplyTextureConfig(coche, config)
		if success then
			print("[CarSuit] ✓ Texturas aplicadas para EquipType " .. equipType)
		end
	end

	-- Copiar apariencia al conductor
	pcall(function()
		local descripcion = humanoid:GetAppliedDescription()
		conductorHumanoid:ApplyDescription(descripcion)
	end)

	-- Configurar animaciones
	local animIdle = Instance.new("Animation")
	animIdle.AnimationId = ANIM_IDLE
	estadoCoche.trackIdle = conductorAnimator:LoadAnimation(animIdle)
	estadoCoche.trackIdle.Priority = Enum.AnimationPriority.Action
	estadoCoche.trackIdle.Looped = true

	local animLeft = Instance.new("Animation")
	animLeft.AnimationId = ANIM_LEFT
	estadoCoche.trackLeft = conductorAnimator:LoadAnimation(animLeft)
	estadoCoche.trackLeft.Priority = Enum.AnimationPriority.Action2
	estadoCoche.trackLeft.Looped = true

	local animRight = Instance.new("Animation")
	animRight.AnimationId = ANIM_RIGHT
	estadoCoche.trackRight = conductorAnimator:LoadAnimation(animRight)
	estadoCoche.trackRight.Priority = Enum.AnimationPriority.Action2
	estadoCoche.trackRight.Looped = true

	estadoCoche.trackIdle:Play()
	estadoCoche.animActual = "idle"

	-- Actualizar raycast params
	raycastParams.FilterDescendantsInstances = {character, coche}

	-- Función para obtener pitch del suelo
	-- Toma en cuenta la rotación del modelo para calcular correctamente frente/atrás
	local function obtenerPitchSuelo()
		local lookVector = rootPart.CFrame.LookVector

		-- Si rotacionY está cerca de 0 (o > 270), el frente del coche está opuesto al jugador
		-- Invertimos el lookVector para que el raycast sea correcto
		local estaInvertido = (rotacionY < 90) or (rotacionY > 270)
		if estaInvertido then
			lookVector = -lookVector
		end

		local posicionFrente = rootPart.Position + lookVector * 3
		local posicionAtras = rootPart.Position - lookVector * 3

		local rayFrente = workspace:Raycast(posicionFrente, Vector3.new(0, -RAYCAST_DISTANCIA, 0), raycastParams)
		local rayAtras = workspace:Raycast(posicionAtras, Vector3.new(0, -RAYCAST_DISTANCIA, 0), raycastParams)

		if rayFrente and rayAtras then
			local diferencia = rayAtras.Position.Y - rayFrente.Position.Y
			local pitch = math.atan2(diferencia, 6)
			return math.clamp(pitch, -PITCH_MAXIMO, PITCH_MAXIMO)
		end

		return 0
	end

	-- Función para actualizar animación
	local function actualizarAnimacion(nuevaAnim)
		if estadoCoche.animActual == nuevaAnim then return end

		if estadoCoche.animActual == "left" then
			estadoCoche.trackLeft:Stop(0.2)
		elseif estadoCoche.animActual == "right" then
			estadoCoche.trackRight:Stop(0.2)
		end

		if nuevaAnim == "left" then
			estadoCoche.trackLeft:Play(0.2)
		elseif nuevaAnim == "right" then
			estadoCoche.trackRight:Play(0.2)
		end

		estadoCoche.animActual = nuevaAnim
	end

	-- Conectar RenderStepped
	estadoCoche.renderConnection = RunService.RenderStepped:Connect(function(dt)
		-- Verificar que el coche sigue existiendo
		if not estadoCoche.carroceria or not estadoCoche.carroceria.Parent then
			return
		end

		-- Actualizar animación según input
		if teclas.izquierda and not teclas.derecha then
			actualizarAnimacion("left")
		elseif teclas.derecha and not teclas.izquierda then
			actualizarAnimacion("right")
		else
			actualizarAnimacion("idle")
		end

		-- Calcular inclinación
		local pitchObjetivo = obtenerPitchSuelo()
		estadoCoche.pitchActual = estadoCoche.pitchActual + (pitchObjetivo - estadoCoche.pitchActual) * dt * VELOCIDAD_INCLINACION

		-- Posicionar carrocería
		local rotacionBase = rootPart.CFrame - rootPart.Position
		local inclinacion = CFrame.Angles(estadoCoche.pitchActual, 0, 0)
		local rotacion = CFrame.Angles(0, math.rad(estadoCoche.rotacionY), 0)

		estadoCoche.carroceria.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, estadoCoche.offsetY, 0)) * rotacionBase * rotacion * inclinacion

		-- Rotación de ruedas
		-- Si el modelo está invertido (rotación < 90 o > 270), las ruedas giran al revés visualmente
		local velocidad = rootPart.AssemblyLinearVelocity.Magnitude
		local direccionRueda = ((rotacionY < 90) or (rotacionY > 270)) and -1 or 1
		estadoCoche.anguloRotacionRueda = estadoCoche.anguloRotacionRueda + (velocidad / RADIO_RUEDA) * dt * direccionRueda

		for _, motorData in pairs(estadoCoche.motoresRuedasDelanteras) do
			motorData.motor.C0 = motorData.offset * CFrame.Angles(estadoCoche.anguloRotacionRueda, 0, 0)
		end

		for _, motorData in pairs(estadoCoche.motoresRuedasTraseras) do
			motorData.motor.C0 = motorData.offset * CFrame.Angles(estadoCoche.anguloRotacionRueda, 0, 0)
		end
	end)

	print("[CarSuit] ✓ Coche configurado: " .. nombreCoche .. " (EquipType " .. equipType .. ")")
	return true
end

-- ═══════════════════════════════════════════════════════════════════════
-- INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════════════════

-- Ocultar personaje real (solo una vez)
ocultarPersonajeReal()

-- Desactivar animaciones del personaje real
local animate = character:FindFirstChild("Animate")
if animate then
	animate:Destroy()
end

-- Obtener EquipType inicial
local equipTypeInicial = getInitialEquipType()
if _G.CurrentCarEquipType then
	equipTypeInicial = _G.CurrentCarEquipType
end

-- Setup inicial del coche
setupCoche(equipTypeInicial)

-- Teleportar si hay posición guardada
if _G.RespawnPosition then
	task.wait(0.1)
	rootPart.CFrame = CFrame.new(_G.RespawnPosition)
	_G.RespawnPosition = nil
	print("[CarSuit] ✓ Teleportado a posición guardada")
end

-- ═══════════════════════════════════════════════════════════════════════
-- CONTROL DE INPUT (persistente entre cambios de coche)
-- ═══════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
		teclas.izquierda = true
	elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
		teclas.derecha = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
		teclas.izquierda = false
	elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
		teclas.derecha = false
	end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- ESTADOS DEL HUMANOID
-- ═══════════════════════════════════════════════════════════════════════
humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

humanoid.StateChanged:Connect(function(_, nuevoEstado)
	if nuevoEstado == Enum.HumanoidStateType.Swimming or nuevoEstado == Enum.HumanoidStateType.Climbing then
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- LIMPIEZA AL MORIR O SALIR
-- ═══════════════════════════════════════════════════════════════════════
humanoid.Died:Connect(function()
	destruirCocheActual()
end)

player.CharacterRemoving:Connect(function()
	destruirCocheActual()
end)

-- ═══════════════════════════════════════════════════════════════════════
-- EXPORTAR FUNCIONES GLOBALES
-- ═══════════════════════════════════════════════════════════════════════

-- Cambio de texturas (instantáneo, sin cambiar modelo)
local function changeCarTextures(newEquipType: number)
	if not estadoCoche.coche or not estadoCoche.coche.Parent then
		warn("[CarSuit] No hay coche activo para cambiar texturas")
		return false
	end

	local newConfig = CarConfigs[newEquipType]
	if not newConfig then
		warn("[CarSuit] Config no encontrada para EquipType " .. newEquipType)
		return false
	end

	if newConfig.Type ~= "Texture" then
		warn("[CarSuit] EquipType " .. newEquipType .. " no es de tipo Texture, usa ChangeCarModel")
		return false
	end

	local success = CarCustomizationUtils.ApplyTextureConfig(estadoCoche.coche, newConfig)
	if success then
		estadoCoche.equipTypeActual = newEquipType
		print("[CarSuit] ✓ Texturas cambiadas a EquipType " .. newEquipType)
	else
		warn("[CarSuit] ⚠ Error cambiando texturas a EquipType " .. newEquipType)
	end

	return success
end

-- Cambio de modelo completo (destruye y recrea el coche)
local function changeCarModel(newEquipType: number)
	local newConfig = CarConfigs[newEquipType]
	if not newConfig then
		warn("[CarSuit] Config no encontrada para EquipType " .. newEquipType)
		return false
	end

	print("[CarSuit] ⟳ Cambiando modelo a EquipType " .. newEquipType)

	-- Destruir coche actual
	destruirCocheActual()

	-- Crear nuevo coche
	local success = setupCoche(newEquipType)

	if success then
		print("[CarSuit] ✓ Modelo cambiado exitosamente a EquipType " .. newEquipType)
	else
		warn("[CarSuit] ❌ Error cambiando modelo a EquipType " .. newEquipType)
		-- Intentar restaurar el modelo anterior
		setupCoche(estadoCoche.equipTypeActual or 1)
	end

	return success
end

_G.ChangeCarTextures = changeCarTextures
_G.ChangeCarModel = changeCarModel

print("[CarSuit] ✅ Sistema Car-Suit inicializado con soporte para cambio dinámico")
