local RunService = game:GetService("RunService")
local character = script.Parent
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ========== DESHABILITAR SONIDOS DEL HUMANOID ==========
local function deshabilitarSonidosHumanoid()
	local sonidosADeshabilitar = {
		"Running",
		"Jumping",
		"Landing",
		"Climbing",
		"GettingUp",
		"FreeFalling",
		"Splash",
		"Swimming",
	}

	for _, nombreSonido in ipairs(sonidosADeshabilitar) do
		local sonido = rootPart:FindFirstChild(nombreSonido)
		if sonido then
			sonido.Volume = 0
		end
	end
end

deshabilitarSonidosHumanoid()
rootPart.ChildAdded:Connect(function(child)
	if child:IsA("Sound") then
		task.wait()
		deshabilitarSonidosHumanoid()
	end
end)
-- ========================================================

-- ========== CONFIGURACIÓN ==========
local ID_LOW  = "rbxassetid://96527617819964" -- Sonido grave/pesado
local ID_MED  = "rbxassetid://75711152458818" -- Sonido de aceleración media
local ID_HIGH = "rbxassetid://92379305033455" -- Sonido agudo/escape

local VEL_MAX = 300     -- Velocidad máxima del coche
local ACELERACION = 10   -- Qué tan rápido sube el sonido (menor = más pesado)
local FRENADO = 4       -- Qué tan rápido cae el sonido al soltar el acelerador
local VEL_PITCH_MAX = 100 -- Velocidad a partir de la cual el pitch no sube más
local PITCH_MAX = 0.75 + ((VEL_PITCH_MAX / VEL_MAX) * 0.75) -- Pitch calculado a 100 de velocidad = 1.0
-- ===================================
local SoundService = game:GetService("SoundService")

-- ========== CONFIGURACIÓN DE GRUPO ==========
-- Esperamos a que el grupo SFX exista. 
-- Si no existe, el motor se escuchará en el canal principal por defecto.
local sfxGroup = SoundService:WaitForChild("SFX", 5) 
-- ============================================

local function crearCapa(nombre, id)
	local s = Instance.new("Sound")
	s.Name = nombre
	s.SoundId = id
	s.Looped = true
	s.Volume = 0

	-- ASIGNACIÓN AL GRUPO SFX
	if sfxGroup then
		s.SoundGroup = sfxGroup
	end

	s.Parent = rootPart
	s:Play()
	return s
end

local sLow  = crearCapa("LowLayer", ID_LOW)
local sMed  = crearCapa("MedLayer", ID_MED)
local sHigh = crearCapa("HighLayer", ID_HIGH)

local rpmVirtual = 0 -- Nuestra variable mágica
local humanoid = character:WaitForChild("Humanoid")

RunService.RenderStepped:Connect(function(dt)
	-- 1. OBTENER VELOCIDAD REAL
	local velReal = rootPart.AssemblyLinearVelocity.Magnitude
	local targetAlpha = math.clamp(velReal / VEL_MAX, 0, 1)

	-- 2. GENERAR EL EFECTO PROGRESIVO (Inercia)
	local velocidadCambio = (targetAlpha > rpmVirtual) and ACELERACION or FRENADO
	rpmVirtual = rpmVirtual + (targetAlpha - rpmVirtual) * (dt * velocidadCambio)

	-- Detectar si está cayendo al vacío para silenciar el motor
	-- Solo reducir volumen si la velocidad vertical es muy negativa (cayendo rápido)
	local volumeMultiplier = 1
	local velocidadVertical = rootPart.AssemblyLinearVelocity.Y
	if velocidadVertical < -100 then -- Cayendo muy rápido (más de 100 studs/s hacia abajo)
		volumeMultiplier = 0.1 -- Reducir volumen a 10% cuando está cayendo al vacío
	end

	-- 3. MEZCLA DE CAPAS (Cross-fading)
	sLow.Volume = math.clamp(1 - (rpmVirtual * 2.5), 0, 0.7) * volumeMultiplier
	sMed.Volume = math.sin(rpmVirtual * math.pi) * 0.8 * volumeMultiplier
	sHigh.Volume = math.clamp((rpmVirtual - 0.4) * 2, 0, 0.8) * volumeMultiplier

	-- 4. VARIACIÓN DE PITCH (Tono)
	local pitchBase = math.clamp(0.75 + (rpmVirtual * 0.75), 0.75, PITCH_MAX)
	sLow.PlaybackSpeed = pitchBase
	sMed.PlaybackSpeed = pitchBase
	sHigh.PlaybackSpeed = pitchBase
end)