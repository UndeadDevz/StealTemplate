-- LocalScript "CarSuit" en StarterCharacterScripts
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
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local lowerTorso = character:WaitForChild("LowerTorso")

-- ========== OBTENER EQUIPTYPE INICIAL ==========
local function getInitialEquipType()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local equipTypeStat = leaderstats:FindFirstChild("EquipType")
		if equipTypeStat then
			return equipTypeStat.Value
		end
	end
	return 1 -- Default
end

local equipTypeActual = getInitialEquipType()

-- Si hay un cambio de modelo pendiente por recarga, usar ese
if _G.CurrentCarEquipType then
	equipTypeActual = _G.CurrentCarEquipType
end

-- ========== CONFIGURACIÓN ==========
-- Determinar el modelo base según el EquipType
local NOMBRE_COCHE = CarCustomizationUtils.GetModelName(equipTypeActual, CarConfigs)
local ANGULO_GIRO_VOLANTE = 45
local VELOCIDAD_GIRO = 10

-- Altura del auto (ajusta este valor para subir o bajar el coche)
local ALTURA_AUTO = 0.2 -- Aumenta para subir, disminuye para bajar

-- Animaciones
local ANIM_IDLE = "rbxassetid://72471066577154"
local ANIM_LEFT = "rbxassetid://136541988317425"
local ANIM_RIGHT = "rbxassetid://88962280420603"

-- Configuración del Raycast para rampas
local RAYCAST_DISTANCIA = 10
local VELOCIDAD_INCLINACION = 8
local PITCH_MAXIMO = math.rad(35)

-- Configuración de ruedas
local RADIO_RUEDA = 1 -- Radio de las ruedas (ajustar según tu modelo)
-- ===================================

-- Calcular offset de altura una sola vez
local offsetY = -humanoid.HipHeight + (lowerTorso.Size.Y / 2) + ALTURA_AUTO

-- ========== OCULTAR PERSONAJE REAL ==========
local function ocultarPersonajeReal()
	-- Ocultar todas las partes del personaje excepto HumanoidRootPart
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

	-- Ocultar la cara (Face)
	local head = character:FindFirstChild("Head")
	if head then
		local face = head:FindFirstChild("face") or head:FindFirstChild("Face")
		if face and face:IsA("Decal") then
			face.Transparency = 1
		end
	end

	-- Listener para nuevas partes que se agreguen al personaje
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

ocultarPersonajeReal()

-- Desactivar animaciones del personaje real
local animate = character:FindFirstChild("Animate")
if animate then
	animate:Destroy()
end

-- ========== CLONAR COCHE CON CONDUCTOR ==========
local cocheOriginal = ReplicatedStorage:WaitForChild(NOMBRE_COCHE)
local coche = cocheOriginal:Clone()
coche.Parent = workspace

-- Configurar partes del coche
local auto = coche:FindFirstChild("auto")
if not auto then
	warn("[CarSuit] ❌ No se encontró 'auto' en el coche!")
	return
end

-- Buscar el Body que contiene el MeshPart principal
local bodyModel = auto:FindFirstChild("Body")
if not bodyModel then
	warn("[CarSuit] ❌ No se encontró 'Body' dentro de auto!")
	return
end

-- Buscar el MeshPart dentro de Body
local carroceria = nil
for _, child in pairs(bodyModel:GetDescendants()) do
	if child:IsA("MeshPart") then
		carroceria = child
		break
	end
end

if not carroceria then
	warn("[CarSuit] ❌ No se encontró MeshPart dentro de Body!")
	return
end

-- Buscar conductor y volante
local conductor = coche:FindFirstChild("Conductor")
if not conductor then
	warn("[CarSuit] ❌ No se encontró 'Conductor' en el coche!")
	return
end

-- Renombrar el conductor con el nombre del jugador
conductor.Name = player.Name

local conductorHumanoid = conductor:WaitForChild("Humanoid")
conductorHumanoid.PlatformStand = true
local conductorAnimator = conductorHumanoid:WaitForChild("Animator")

-- Buscar volante en el coche
local volante = coche:FindFirstChild("Volante", true) -- true = búsqueda recursiva
if not volante then
	warn("[CarSuit] ⚠ No se encontró 'Volante' en el coche (continuando sin volante)")
end

-- Primero configurar todas las partes como no colisionables
for _, parte in pairs(coche:GetDescendants()) do
	if parte:IsA("BasePart") then
		parte.CanCollide = false
	end
end

-- Anclar solo la carrocería
carroceria.Anchored = true

-- Obtener ruedas individuales
local frontLeftTire = auto:FindFirstChild("FrontLeftTire")
local frontRightTire = auto:FindFirstChild("FrontRightTire")
local backRightTire = auto:FindFirstChild("BackRightTire")
local backLeftTire = auto:FindFirstChild("BackLelfTire") -- Nota: tiene un typo "Lelf" en el modelo

if not frontLeftTire then warn("[CarSuit] ⚠ No se encontró 'FrontLeftTire'") end
if not frontRightTire then warn("[CarSuit] ⚠ No se encontró 'FrontRightTire'") end
if not backRightTire then warn("[CarSuit] ⚠ No se encontró 'BackRightTire'") end
if not backLeftTire then warn("[CarSuit] ⚠ No se encontró 'BackLelfTire'") end

-- ========== SOLDAR PARTES DEL AUTO (EXCEPTO RUEDAS) ==========
-- Función para verificar si una parte está dentro de un modelo "Wheel" (NO "Brake")
local function estaEnModeloWheel(parte)
	local parent = parte.Parent
	while parent and parent ~= auto do
		if parent:IsA("Model") and parent.Name == "Wheel" then
			return true
		end
		parent = parent.Parent
	end
	return false
end

-- Soldar partes que NO son las ruedas (Wheel)
-- Los frenos (Brake) SÍ se sueldan a la carrocería
local frenosSoldados = 0
for _, parte in pairs(auto:GetDescendants()) do
	if parte:IsA("BasePart") and parte ~= carroceria then
		-- Solo excluir si está dentro de un modelo "Wheel" (Tire + Rim)
		-- Los "Brake" se soldarán normalmente
		if not estaEnModeloWheel(parte) then
			-- Verificar si es un freno para el contador
			local parent = parte.Parent
			local esBrake = false
			while parent and parent ~= auto do
				if parent:IsA("Model") and parent.Name == "Brake" then
					esBrake = true
					frenosSoldados = frenosSoldados + 1
					break
				end
				parent = parent.Parent
			end

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = carroceria
			weld.Part1 = parte
			weld.Parent = carroceria
		end
	end
end

print("[CarSuit] ✓ Partes soldadas - Frenos: " .. frenosSoldados)

-- ========== CONFIGURAR RUEDAS CON MOTOR6D ==========
local motoresRuedasDelanteras = {}
local motoresRuedasTraseras = {}
local anguloRotacionRueda = 0

-- Función para encontrar el MeshPart principal de una rueda (dentro del modelo "Wheel")
local function encontrarMeshPartRueda(tireModel)
	if not tireModel then return nil end

	-- Buscar el modelo "Wheel" dentro del modelo de neumático
	local wheelModel = tireModel:FindFirstChild("Wheel")
	if not wheelModel then
		warn("[CarSuit] ⚠ No se encontró modelo 'Wheel' dentro de " .. tireModel.Name)
		return nil
	end

	-- Primero intentar encontrar el Tire dentro de Wheel
	local tireSubModel = wheelModel:FindFirstChild("Tire")
	if tireSubModel then
		-- Buscar el primer MeshPart dentro de Tire
		for _, desc in pairs(tireSubModel:GetDescendants()) do
			if desc:IsA("MeshPart") then
				return desc
			end
		end
	end

	-- Si no encontramos Tire o no tiene MeshPart, buscar en Rim
	local rimModel = wheelModel:FindFirstChild("Rim")
	if rimModel then
		for _, desc in pairs(rimModel:GetDescendants()) do
			if desc:IsA("MeshPart") then
				return desc
			end
		end
	end

	-- Como último recurso, devolver el primer MeshPart dentro de "Wheel"
	for _, desc in pairs(wheelModel:GetDescendants()) do
		if desc:IsA("MeshPart") then
			return desc
		end
	end

	return nil
end

-- Función para soldar todas las partes dentro de Wheel (Tire + Rim) entre sí
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

-- Función para crear Motor6D para una rueda
local function crearMotorRueda(tireModel, esDelantera, nombreRueda)
	local ruedaMesh = encontrarMeshPartRueda(tireModel)
	if not ruedaMesh then
		warn("[CarSuit] ❌ No se encontró MeshPart en " .. nombreRueda)
		return nil
	end

	-- Soldar todas las partes de Wheel (Tire + Rim) a la rueda principal
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

	print("[CarSuit] ✓ " .. nombreRueda .. " conectada")
	return motor
end

-- Conectar ruedas delanteras
if frontLeftTire then
	local motor = crearMotorRueda(frontLeftTire, true, "FrontLeftTire")
	if motor then
		table.insert(motoresRuedasDelanteras, {motor = motor, offset = motor.C0})
	end
end

if frontRightTire then
	local motor = crearMotorRueda(frontRightTire, true, "FrontRightTire")
	if motor then
		table.insert(motoresRuedasDelanteras, {motor = motor, offset = motor.C0})
	end
end

-- Conectar ruedas traseras
if backRightTire then
	local motor = crearMotorRueda(backRightTire, false, "BackRightTire")
	if motor then
		table.insert(motoresRuedasTraseras, {motor = motor, offset = motor.C0})
	end
end

if backLeftTire then
	local motor = crearMotorRueda(backLeftTire, false, "BackLeftTire")
	if motor then
		table.insert(motoresRuedasTraseras, {motor = motor, offset = motor.C0})
	end
end
-- ========================================================

-- Soldar TODAS las partes del conductor a la carrocería
for _, parte in pairs(conductor:GetDescendants()) do
	if parte:IsA("BasePart") then
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = carroceria
		weld.Part1 = parte
		weld.Parent = carroceria
	end
end

-- Guardar offset del volante respecto al coche (solo si existe)
local volanteOffset = nil
local motorVolante = nil

if volante then
	volanteOffset = carroceria.CFrame:ToObjectSpace(volante.CFrame)

	-- Motor6D para el volante
	motorVolante = Instance.new("Motor6D")
	motorVolante.Name = "VolanteMotor"
	motorVolante.Part0 = carroceria
	motorVolante.Part1 = volante
	motorVolante.C0 = volanteOffset
	motorVolante.Parent = carroceria

	print("[CarSuit] ✓ Volante conectado")
else
	print("[CarSuit] ⚠ Auto sin volante")
end
-- ========================================================

-- ========== APLICAR TEXTURAS SEGÚN CONFIG ==========
local configActual = CarConfigs[equipTypeActual]
if configActual and configActual.Type == "Texture" then
	local success = CarCustomizationUtils.ApplyTextureConfig(coche, configActual)
	if success then
		print("[CarSuit] ✓ Texturas aplicadas para EquipType " .. equipTypeActual)
	else
		warn("[CarSuit] ⚠ Error aplicando texturas para EquipType " .. equipTypeActual)
	end
end
-- ========================================================

-- ========== COPIAR APARIENCIA AL CONDUCTOR ==========
local function copiarApariencia()
	local descripcion = humanoid:GetAppliedDescription()
	conductorHumanoid:ApplyDescription(descripcion)
end

pcall(copiarApariencia)

-- ========== ANIMACIONES DEL CONDUCTOR ==========
local animIdle = Instance.new("Animation")
animIdle.AnimationId = ANIM_IDLE
local trackIdle = conductorAnimator:LoadAnimation(animIdle)
trackIdle.Priority = Enum.AnimationPriority.Action
trackIdle.Looped = true

local animLeft = Instance.new("Animation")
animLeft.AnimationId = ANIM_LEFT
local trackLeft = conductorAnimator:LoadAnimation(animLeft)
trackLeft.Priority = Enum.AnimationPriority.Action2
trackLeft.Looped = true

local animRight = Instance.new("Animation")
animRight.AnimationId = ANIM_RIGHT
local trackRight = conductorAnimator:LoadAnimation(animRight)
trackRight.Priority = Enum.AnimationPriority.Action2
trackRight.Looped = true

trackIdle:Play()

-- ========== CONTROL DE INPUT ==========
local anguloActual = 0
local anguloObjetivo = 0

local teclas = {
	izquierda = false,
	derecha = false
}

local animActual = "idle"

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

local function actualizarAnimacion(nuevaAnim)
	if animActual == nuevaAnim then return end

	if animActual == "left" then
		trackLeft:Stop(0.2)
	elseif animActual == "right" then
		trackRight:Stop(0.2)
	end

	if nuevaAnim == "left" then
		trackLeft:Play(0.2)
	elseif nuevaAnim == "right" then
		trackRight:Play(0.2)
	end

	animActual = nuevaAnim
end

-- ========== RAYCAST PARA INCLINACIÓN ==========
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {character, coche}

local pitchActual = 0

local function obtenerPitchSuelo()
	local lookVector = rootPart.CFrame.LookVector
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

-- ========== BUCLE PRINCIPAL ==========
RunService.RenderStepped:Connect(function(dt)
	if teclas.izquierda and not teclas.derecha then
		anguloObjetivo = ANGULO_GIRO_VOLANTE
		actualizarAnimacion("left")
	elseif teclas.derecha and not teclas.izquierda then
		anguloObjetivo = -ANGULO_GIRO_VOLANTE
		actualizarAnimacion("right")
	else
		anguloObjetivo = 0
		actualizarAnimacion("idle")
	end

	anguloActual = anguloActual + (anguloObjetivo - anguloActual) * dt * VELOCIDAD_GIRO

	-- Actualizar volante solo si existe
	if motorVolante and volanteOffset then
		motorVolante.C0 = volanteOffset * CFrame.Angles(0, math.rad(anguloActual), 0)
	end

	local pitchObjetivo = obtenerPitchSuelo()
	pitchActual = pitchActual + (pitchObjetivo - pitchActual) * dt * VELOCIDAD_INCLINACION

	local rotacionBase = rootPart.CFrame - rootPart.Position
	local inclinacion = CFrame.Angles(pitchActual, 0, 0)
	local rotacion180 = CFrame.Angles(0, math.rad(180), 0) -- Rotar 180 grados para corregir dirección

	carroceria.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, offsetY, 0)) * rotacionBase * rotacion180 * inclinacion

	-- ========== ROTACIÓN DE RUEDAS ==========
	-- Calcular rotación de ruedas basada en velocidad (solo adelante/atrás)
	local velocidad = rootPart.AssemblyLinearVelocity.Magnitude
	anguloRotacionRueda = anguloRotacionRueda + (velocidad / RADIO_RUEDA) * dt

	-- Actualizar ruedas delanteras (solo rotan, no doblan)
	for _, motorData in pairs(motoresRuedasDelanteras) do
		local motor = motorData.motor
		local offset = motorData.offset
		-- Solo rotación en X (adelante/atrás)
		motor.C0 = offset * CFrame.Angles(anguloRotacionRueda, 0, 0)
	end

	-- Actualizar ruedas traseras (solo rotan)
	for _, motorData in pairs(motoresRuedasTraseras) do
		local motor = motorData.motor
		local offset = motorData.offset
		-- Solo rotación en X (adelante/atrás)
		motor.C0 = offset * CFrame.Angles(anguloRotacionRueda, 0, 0)
	end
	-- ========================================================
end)

-- ========== ESTADOS DEL HUMANOID ==========
humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

humanoid.StateChanged:Connect(function(_, nuevoEstado)
	if nuevoEstado == Enum.HumanoidStateType.Swimming or nuevoEstado == Enum.HumanoidStateType.Climbing then
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
end)

-- ========== LIMPIEZA ==========
humanoid.Died:Connect(function()
	coche:Destroy()
end)

player.CharacterRemoving:Connect(function()
	coche:Destroy()
end)

-- Teleportar a la posición guardada si existe (cuando se cambió de modelo)
if _G.RespawnPosition then
	task.wait(0.1) -- Pequeña espera para asegurar que todo está cargado
	rootPart.CFrame = CFrame.new(_G.RespawnPosition)
	_G.RespawnPosition = nil -- Limpiar después de usar
	print("[CarSuit] ✓ Teleportado a posición guardada")
end

-- ========== EXPORTAR FUNCIÓN DE CAMBIO DE TEXTURAS ==========
-- Esta función permite cambiar texturas dinámicamente sin recargar el personaje
local function changeCarTextures(newEquipType: number)
	if not coche or not coche.Parent then
		warn("[CarSuit] No hay coche activo para cambiar texturas")
		return false
	end

	local newConfig = CarConfigs[newEquipType]
	if not newConfig then
		warn("[CarSuit] Config no encontrada para EquipType " .. newEquipType)
		return false
	end

	if newConfig.Type ~= "Texture" then
		warn("[CarSuit] EquipType " .. newEquipType .. " no es de tipo Texture")
		return false
	end

	local success = CarCustomizationUtils.ApplyTextureConfig(coche, newConfig)
	if success then
		equipTypeActual = newEquipType
		print("[CarSuit] ✓ Texturas cambiadas a EquipType " .. newEquipType)
	else
		warn("[CarSuit] ⚠ Error cambiando texturas a EquipType " .. newEquipType)
	end

	return success
end

_G.ChangeCarTextures = changeCarTextures
print("[CarSuit] ✓ Función de cambio de texturas exportada")
-- ========================================================

print("[CarSuit] ✓ Car-Suit listo!")
