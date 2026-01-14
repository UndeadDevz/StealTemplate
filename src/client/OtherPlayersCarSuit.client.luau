--[[
	═══════════════════════════════════════════════════════════════════════
	OTHER PLAYERS CARSUIT CLIENT
	═══════════════════════════════════════════════════════════════════════

	Este script crea coches para OTROS jugadores (no el jugador local).
	Cada cliente crea y renderiza los coches de los demás jugadores.

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Importar módulos del sistema híbrido
local Shared = ReplicatedStorage:WaitForChild("Shared")
local CarConfigs = require(Shared:WaitForChild("CarConfigs"))
local CarCustomizationUtils = require(Shared:WaitForChild("CarCustomizationUtils"))

local localPlayer = Players.LocalPlayer

-- ========== CONFIGURACIÓN ==========
local NOMBRE_COCHE_DEFAULT = "CocheMesh"
local RADIO_RUEDA = 1

-- Animaciones
local ANIM_IDLE = "rbxassetid://94863045736134"
local ANIM_LEFT = "rbxassetid://102025087016232"
local ANIM_RIGHT = "rbxassetid://99169459312919"

-- Sonidos del motor
local ID_LOW  = "rbxassetid://113585940003370"
local ID_MED  = "rbxassetid://75711152458818"
local ID_HIGH = "rbxassetid://92379305033455"
local VEL_MAX = 300
local ACELERACION = 10
local FRENADO = 4
local VEL_PITCH_MAX = 100 -- Velocidad a partir de la cual el pitch no sube más
local PITCH_MAX = 0.75 + ((VEL_PITCH_MAX / VEL_MAX) * 0.75) -- Pitch calculado a 100 de velocidad = 1.0

-- Umbral para detectar giro
local UMBRAL_GIRO = 0.5 -- Velocidad angular para detectar giro
-- ===================================

-- Tabla para guardar los coches de otros jugadores
local otherPlayerCars = {}

-- Función para ocultar el personaje de otro jugador
local function ocultarPersonaje(character)
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

-- Función para encontrar el MeshPart principal de una rueda
local function encontrarMeshPartRueda(tireModel)
	if not tireModel then return nil end

	local wheelModel = tireModel:FindFirstChild("Wheel")
	if not wheelModel then return nil end

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

-- Función para soldar todas las partes dentro de Wheel
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

-- Función para verificar si una parte está dentro de un modelo "Wheel"
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

-- Función para crear un coche para otro jugador
local function crearCocheParaOtroJugador(player, character)
	-- Ocultar el personaje del otro jugador (para nosotros)
	ocultarPersonaje(character)

	local humanoid = character:WaitForChild("Humanoid", 5)
	local rootPart = character:WaitForChild("HumanoidRootPart", 5)
	local lowerTorso = character:FindFirstChild("LowerTorso")

	if not lowerTorso then
		warn("[OtherPlayersCarSuit] ⚠ No se encontró LowerTorso en " .. player.Name)
		return
	end

	-- Obtener EquipType del jugador desde Attribute
	local equipType = player:GetAttribute("EquipType") or 1

	-- Obtener configuración del EquipType
	local configActual = CarConfigs[equipType]
	local alturaAuto = configActual and configActual.AlturaAuto or 0.8
	local rotacionY = configActual and configActual.Rotacion or 180

	-- Obtener el nombre del modelo según el EquipType usando el sistema híbrido
	local nombreCoche = CarCustomizationUtils.GetModelName(equipType, CarConfigs)

	-- Clonar coche
	local cocheOriginal = ReplicatedStorage:FindFirstChild(nombreCoche)
	if not cocheOriginal then
		warn("[OtherPlayersCarSuit] ⚠ No se encontró modelo '" .. nombreCoche .. "' en ReplicatedStorage")
		cocheOriginal = ReplicatedStorage:WaitForChild(NOMBRE_COCHE_DEFAULT)
	end

	local coche = cocheOriginal:Clone()
	coche.Name = player.Name .. "_Car"
	coche.Parent = workspace

	-- Configurar partes del coche
	local auto = coche:FindFirstChild("auto")
	if not auto then
		warn("[OtherPlayersCarSuit] ❌ No se encontró 'auto' en el coche!")
		coche:Destroy()
		return
	end

	local bodyModel = auto:FindFirstChild("Body")
	if not bodyModel then
		warn("[OtherPlayersCarSuit] ❌ No se encontró 'Body' dentro de auto!")
		coche:Destroy()
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
		warn("[OtherPlayersCarSuit] ❌ No se encontró MeshPart dentro de Body!")
		coche:Destroy()
		return
	end

	-- Buscar conductor
	local conductor = coche:FindFirstChild("Conductor")
	if not conductor then
		warn("[OtherPlayersCarSuit] ❌ No se encontró 'Conductor' en el coche!")
		coche:Destroy()
		return
	end

	-- Renombrar el conductor con el nombre del jugador
	conductor.Name = player.Name

	local conductorHumanoid = conductor:WaitForChild("Humanoid")
	conductorHumanoid.PlatformStand = true
	local conductorAnimator = conductorHumanoid:WaitForChild("Animator")

	-- Configurar todas las partes como no colisionables
	for _, parte in pairs(coche:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.CanCollide = false
		end
	end

	-- Anclar solo la carrocería
	carroceria.Anchored = true

	-- Obtener ruedas
	local frontLeftTire = auto:FindFirstChild("FrontLeftTire")
	local frontRightTire = auto:FindFirstChild("FrontRightTire")
	local backRightTire = auto:FindFirstChild("BackRightTire")
	local backLeftTire = auto:FindFirstChild("BackLelfTire")

	-- Soldar partes que NO son las ruedas
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

	-- Configurar ruedas con Motor6D
	local motoresRuedasDelanteras = {}
	local motoresRuedasTraseras = {}

	local function crearMotorRueda(tireModel, nombreRueda)
		local ruedaMesh = encontrarMeshPartRueda(tireModel)
		if not ruedaMesh then return nil end

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

	-- Conectar ruedas
	if frontLeftTire then
		local motor = crearMotorRueda(frontLeftTire, "FrontLeftTire")
		if motor then
			table.insert(motoresRuedasDelanteras, {motor = motor, offset = motor.C0})
		end
	end

	if frontRightTire then
		local motor = crearMotorRueda(frontRightTire, "FrontRightTire")
		if motor then
			table.insert(motoresRuedasDelanteras, {motor = motor, offset = motor.C0})
		end
	end

	if backRightTire then
		local motor = crearMotorRueda(backRightTire, "BackRightTire")
		if motor then
			table.insert(motoresRuedasTraseras, {motor = motor, offset = motor.C0})
		end
	end

	if backLeftTire then
		local motor = crearMotorRueda(backLeftTire, "BackLeftTire")
		if motor then
			table.insert(motoresRuedasTraseras, {motor = motor, offset = motor.C0})
		end
	end


	-- Soldar todas las partes del conductor a la carrocería y desactivar colisiones/touch/query
	for _, parte in pairs(conductor:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.CanCollide = false
			parte.CanTouch = false
			parte.CanQuery = false
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = carroceria
			weld.Part1 = parte
			weld.Parent = carroceria
		end
	end

	-- Listener para nuevas partes añadidas al conductor
	conductor.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end
	end)

	-- Copiar apariencia al conductor
	local function copiarApariencia()
		local descripcion = humanoid:GetAppliedDescription()
		conductorHumanoid:ApplyDescription(descripcion)
	end

	pcall(copiarApariencia)

	-- ========== APLICAR TEXTURAS SEGÚN CONFIG ==========
	if configActual and configActual.Type == "Texture" then
		local success = CarCustomizationUtils.ApplyTextureConfig(coche, configActual)
		if success then
			print("[OtherPlayersCarSuit] ✓ Texturas aplicadas para " .. player.Name .. " (EquipType " .. equipType .. ")")
		else
			warn("[OtherPlayersCarSuit] ⚠ Error aplicando texturas para " .. player.Name)
		end
	end
	-- ========================================================

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

	local animActual = "idle"

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

	-- ========== SONIDOS DEL MOTOR ==========
	local function crearCapaSonido(nombre, id)
		local s = Instance.new("Sound")
		s.Name = nombre
		s.SoundId = id
		s.Looped = true
		s.Volume = 0
		s.Parent = rootPart
		s:Play()
		return s
	end

	local sLow = crearCapaSonido("LowLayer", ID_LOW)
	local sMed = crearCapaSonido("MedLayer", ID_MED)
	local sHigh = crearCapaSonido("HighLayer", ID_HIGH)

	local rpmVirtual = 0

	-- Función para obtener el multiplicador de volumen desde settings
	local function getVolumeMultiplier()
		return _G.OtherPlayersVolume or 0.65
	end

	-- Calcular offset de altura usando el valor de la config
	local offsetY = -humanoid.HipHeight + (lowerTorso.Size.Y / 2) + alturaAuto

	-- Variables para seguimiento
	local anguloRotacionRueda = 0
	local cfAnterior = rootPart.CFrame

	-- Conexión para seguir al jugador
	local connection = RunService.RenderStepped:Connect(function(dt)
		if not rootPart or not rootPart.Parent or not coche.Parent or not carroceria.Parent then
			-- Limpiar si algo fue destruido
			if connection then
				connection:Disconnect()
			end
			if coche and coche.Parent then
				coche:Destroy()
			end
			if sLow then sLow:Stop() sLow:Destroy() end
			if sMed then sMed:Stop() sMed:Destroy() end
			if sHigh then sHigh:Stop() sHigh:Destroy() end
			otherPlayerCars[player.UserId] = nil
			return
		end

		-- Seguir la posición del jugador
		local rotacionBase = rootPart.CFrame - rootPart.Position
		local rotacion = CFrame.Angles(0, math.rad(rotacionY), 0)

		carroceria.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, offsetY, 0)) * rotacionBase * rotacion

		-- Calcular velocidad
		local velocidad = rootPart.AssemblyLinearVelocity.Magnitude

		-- ========== DETECTAR DIRECCIÓN DE GIRO ==========
		-- Calcular la velocidad angular en Y (giro horizontal)
		local velocidadAngular = rootPart.AssemblyAngularVelocity.Y

		-- Actualizar animaciones basándose en la velocidad angular
		if math.abs(velocidadAngular) > UMBRAL_GIRO and velocidad > 5 then
			if velocidadAngular > 0 then
				-- Girando a la izquierda
				actualizarAnimacion("left")
			else
				-- Girando a la derecha
				actualizarAnimacion("right")
			end
		else
			actualizarAnimacion("idle")
		end

		-- ========== SONIDOS DEL MOTOR ==========
		local targetAlpha = math.clamp(velocidad / VEL_MAX, 0, 1)
		local velocidadCambio = (targetAlpha > rpmVirtual) and ACELERACION or FRENADO
		rpmVirtual = rpmVirtual + (targetAlpha - rpmVirtual) * (dt * velocidadCambio)

		-- Obtener multiplicador de volumen
		local volumeMultiplier = getVolumeMultiplier()

		-- Detectar si está cayendo al vacío para silenciar el motor
		-- Solo reducir volumen si la velocidad vertical es muy negativa (cayendo rápido)
		local velocidadVertical = rootPart.AssemblyLinearVelocity.Y
		if velocidadVertical < -100 then -- Cayendo muy rápido (más de 100 studs/s hacia abajo)
			volumeMultiplier = volumeMultiplier * 0.1 -- Reducir volumen a 10% cuando está cayendo al vacío
		end

		-- Mezcla de capas (multiplicado por el volumen de settings)
		sLow.Volume = math.clamp(1 - (rpmVirtual * 2.5), 0, 0.7) * volumeMultiplier
		sMed.Volume = math.sin(rpmVirtual * math.pi) * 0.8 * volumeMultiplier
		sHigh.Volume = math.clamp((rpmVirtual - 0.4) * 2, 0, 0.8) * volumeMultiplier

		-- Variación de pitch
		local pitchBase = math.clamp(0.75 + (rpmVirtual * 0.75), 0.75, PITCH_MAX)
		sLow.PlaybackSpeed = pitchBase
		sMed.PlaybackSpeed = pitchBase
		sHigh.PlaybackSpeed = pitchBase

		-- ========== ROTACIÓN DE RUEDAS ==========
		anguloRotacionRueda = anguloRotacionRueda + (velocidad / RADIO_RUEDA) * dt

		-- Actualizar ruedas
		for _, motorData in pairs(motoresRuedasDelanteras) do
			local motor = motorData.motor
			local offset = motorData.offset
			motor.C0 = offset * CFrame.Angles(anguloRotacionRueda, 0, 0)
		end

		for _, motorData in pairs(motoresRuedasTraseras) do
			local motor = motorData.motor
			local offset = motorData.offset
			motor.C0 = offset * CFrame.Angles(anguloRotacionRueda, 0, 0)
		end

		-- Actualizar CFrame anterior
		cfAnterior = rootPart.CFrame
	end)

	-- Limpiar cuando el jugador muere
	humanoid.Died:Connect(function()
		if connection then
			connection:Disconnect()
		end
		if coche and coche.Parent then
			coche:Destroy()
		end
		if sLow then sLow:Stop() sLow:Destroy() end
		if sMed then sMed:Stop() sMed:Destroy() end
		if sHigh then sHigh:Stop() sHigh:Destroy() end
		otherPlayerCars[player.UserId] = nil
	end)

	-- Variable para la conexión del Attribute (se define antes para poder referenciarla)
	local attributeConnection = nil

	-- Guardar referencia (incluir equipType y parámetros para poder comparar después)
	otherPlayerCars[player.UserId] = {
		coche = coche,
		connection = connection,
		attributeConnection = nil, -- Se actualiza después
		equipType = equipType,
		alturaAuto = alturaAuto,
		rotacionY = rotacionY
	}

	-- Escuchar cambios de EquipType via Attribute (más confiable que RemoteEvent)
	attributeConnection = player:GetAttributeChangedSignal("EquipType"):Connect(function()
		local newEquipType = player:GetAttribute("EquipType")
		if not newEquipType or newEquipType == equipType then return end

		print("[OtherPlayersCarSuit] " .. player.Name .. " cambió EquipType: " .. equipType .. " → " .. newEquipType)

		-- Verificar si requiere cambio de modelo
		local requiresModelChange = CarCustomizationUtils.RequiresModelChange(equipType, newEquipType, CarConfigs)

		if requiresModelChange then
			-- Recrear coche completo
			print("[OtherPlayersCarSuit] ⟳ Recreando modelo de " .. player.Name)

			-- Limpiar actual
			if connection then connection:Disconnect() end
			if attributeConnection then attributeConnection:Disconnect() end
			if coche and coche.Parent then coche:Destroy() end
			if sLow then sLow:Stop() sLow:Destroy() end
			if sMed then sMed:Stop() sMed:Destroy() end
			if sHigh then sHigh:Stop() sHigh:Destroy() end
			otherPlayerCars[player.UserId] = nil

			-- Recrear con nuevo modelo
			task.defer(function()
				if player.Character then
					crearCocheParaOtroJugador(player, player.Character)
				end
			end)
		else
			-- Solo cambiar texturas
			local newConfig = CarConfigs[newEquipType]
			if newConfig and newConfig.Type == "Texture" then
				local success = CarCustomizationUtils.ApplyTextureConfig(coche, newConfig)
				if success then
					-- Actualizar equipType local
					equipType = newEquipType
					if otherPlayerCars[player.UserId] then
						otherPlayerCars[player.UserId].equipType = newEquipType
					end
					print("[OtherPlayersCarSuit] ✓ Texturas de " .. player.Name .. " actualizadas")
				end
			end
		end
	end)

	-- Guardar la conexión del Attribute
	if otherPlayerCars[player.UserId] then
		otherPlayerCars[player.UserId].attributeConnection = attributeConnection
	end

	print("[OtherPlayersCarSuit] ✓ Coche creado para " .. player.Name)
end

-- Manejar cuando un jugador se une
local function onPlayerAdded(player)
	-- Ignorar al jugador local
	if player == localPlayer then return end

	-- Si ya tiene personaje, crear coche
	if player.Character then
		task.spawn(function()
			crearCocheParaOtroJugador(player, player.Character)
		end)
	end

	-- Cuando spawn un nuevo personaje
	player.CharacterAdded:Connect(function(character)
		-- Limpiar coche anterior si existe
		if otherPlayerCars[player.UserId] then
			if otherPlayerCars[player.UserId].connection then
				otherPlayerCars[player.UserId].connection:Disconnect()
			end
			if otherPlayerCars[player.UserId].attributeConnection then
				otherPlayerCars[player.UserId].attributeConnection:Disconnect()
			end
			if otherPlayerCars[player.UserId].coche then
				otherPlayerCars[player.UserId].coche:Destroy()
			end
			otherPlayerCars[player.UserId] = nil
		end

		-- Crear nuevo coche
		task.wait(0.5) -- Esperar a que todo cargue
		crearCocheParaOtroJugador(player, character)
	end)
end

-- Función para limpiar todos los coches de un jugador en workspace
local function limpiarCochesDeJugador(playerName)
	-- Buscar por nombre exacto del coche
	local cocheNombre = workspace:FindFirstChild(playerName .. "_Car")
	if cocheNombre then
		cocheNombre:Destroy()
	end

	-- Buscar coches que tengan conductor con el nombre del jugador
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("Model") then
			local conductor = obj:FindFirstChild(playerName)
			if conductor and conductor:FindFirstChild("Humanoid") then
				obj:Destroy()
			end
		end
	end
end

-- Manejar cuando un jugador se va
local function onPlayerRemoving(player)
	-- Limpiar de la tabla
	if otherPlayerCars[player.UserId] then
		if otherPlayerCars[player.UserId].connection then
			otherPlayerCars[player.UserId].connection:Disconnect()
		end
		if otherPlayerCars[player.UserId].attributeConnection then
			otherPlayerCars[player.UserId].attributeConnection:Disconnect()
		end
		if otherPlayerCars[player.UserId].coche then
			otherPlayerCars[player.UserId].coche:Destroy()
		end
		otherPlayerCars[player.UserId] = nil
	end

	-- Limpiar cualquier coche huérfano en workspace
	limpiarCochesDeJugador(player.Name)
end

-- Conectar eventos
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Crear coches para jugadores que ya están en el juego
for _, player in pairs(Players:GetPlayers()) do
	if player ~= localPlayer then
		onPlayerAdded(player)
	end
end

-- NOTA: Los cambios de EquipType de otros jugadores ahora se detectan
-- via GetAttributeChangedSignal dentro de crearCocheParaOtroJugador
-- Esto es más confiable que el RemoteEvent porque los Attributes se replican automáticamente

-- ========== MANEJO DE STREAMING ==========
-- Cuando un jugador sale del rango de streaming y vuelve, recrear su coche
-- Verificar periódicamente si hay jugadores sin coche válido

local STREAMING_CHECK_INTERVAL = 2 -- Verificar cada 2 segundos
local STREAMING_RANGE = 600 -- Rango para considerar jugadores "cercanos"

local creatingCars = {} -- Flag para evitar crear múltiples veces

-- Función para verificar si ya existe un coche en workspace para este jugador
local function existeCocheEnWorkspace(playerName)
	local cocheName = playerName .. "_Car"
	if workspace:FindFirstChild(cocheName) then
		return true
	end
	-- También buscar coches con conductor que tenga el nombre del jugador
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj:FindFirstChild(playerName) then
			local posibleConductor = obj:FindFirstChild(playerName)
			if posibleConductor:FindFirstChild("Humanoid") then
				return true
			end
		end
	end
	return false
end

task.spawn(function()
	while true do
		task.wait(STREAMING_CHECK_INTERVAL)

		local localRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not localRootPart then continue end

		for _, player in pairs(Players:GetPlayers()) do
			if player == localPlayer then continue end
			if creatingCars[player.UserId] then continue end -- Ya está creando

			local character = player.Character
			if not character then continue end

			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if not rootPart then continue end

			-- Verificar distancia
			local distance = (rootPart.Position - localRootPart.Position).Magnitude
			if distance > STREAMING_RANGE then continue end

			-- Verificar si ya existe coche en workspace
			if existeCocheEnWorkspace(player.Name) then continue end

			-- Verificar si tiene coche válido en nuestra tabla
			local playerData = otherPlayerCars[player.UserId]

			if playerData then
				-- Tiene datos, verificar si el coche sigue existiendo
				local cocheValido = playerData.coche
					and playerData.coche.Parent
					and playerData.coche:FindFirstChild("auto")

				if not cocheValido then
					-- El coche fue destruido (probablemente por streaming), recrear
					print("[OtherPlayersCarSuit] Recreando coche de " .. player.Name .. " (streaming)")

					if playerData.connection then
						playerData.connection:Disconnect()
					end
					otherPlayerCars[player.UserId] = nil

					creatingCars[player.UserId] = true
					task.spawn(function()
						crearCocheParaOtroJugador(player, character)
						creatingCars[player.UserId] = nil
					end)
				end
			else
				-- No tiene coche en tabla, crear uno si el personaje está completo
				local humanoid = character:FindFirstChild("Humanoid")
				local lowerTorso = character:FindFirstChild("LowerTorso")

				if humanoid and lowerTorso and rootPart then
					print("[OtherPlayersCarSuit] Creando coche para " .. player.Name .. " (streaming recovery)")
					creatingCars[player.UserId] = true
					task.spawn(function()
						crearCocheParaOtroJugador(player, character)
						creatingCars[player.UserId] = nil
					end)
				end
			end
		end
	end
end)

-- ========== LIMPIEZA PERIÓDICA DE COCHES HUÉRFANOS ==========
-- Cada 10 segundos, limpiar coches de jugadores que ya no existen
task.spawn(function()
	while true do
		task.wait(10)

		-- Crear lista de nombres de jugadores actuales
		local playerNames = {}
		for _, player in pairs(Players:GetPlayers()) do
			playerNames[player.Name] = true
		end

		-- Buscar y destruir coches huérfanos
		for _, obj in pairs(workspace:GetChildren()) do
			if obj:IsA("Model") then
				-- Verificar si es un coche (tiene "auto" adentro)
				if obj:FindFirstChild("auto") then
					-- Buscar si tiene un conductor
					for _, child in pairs(obj:GetChildren()) do
						if child:IsA("Model") and child:FindFirstChild("Humanoid") then
							-- Es un conductor, verificar si el jugador existe
							if not playerNames[child.Name] and child.Name ~= "Conductor" then
								print("[OtherPlayersCarSuit] Limpiando coche huérfano de " .. child.Name)
								obj:Destroy()
								break
							end
						end
					end
				end
			end
		end
	end
end)

print("[OtherPlayersCarSuit] ✓ Sistema inicializado (con soporte de streaming)")
