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
		"Swimming"
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

RunService.RenderStepped:Connect(function(dt)
	-- 1. OBTENER VELOCIDAD REAL
	local velReal = rootPart.AssemblyLinearVelocity.Magnitude
	local targetAlpha = math.clamp(velReal / VEL_MAX, 0, 1)

	-- 2. GENERAR EL EFECTO PROGRESIVO (Inercia)
	local velocidadCambio = (targetAlpha > rpmVirtual) and ACELERACION or FRENADO
	rpmVirtual = rpmVirtual + (targetAlpha - rpmVirtual) * (dt * velocidadCambio)

	-- 3. MEZCLA DE CAPAS (Cross-fading)
	sLow.Volume = math.clamp(1 - (rpmVirtual * 2.5), 0, 0.7)
	sMed.Volume = math.sin(rpmVirtual * math.pi) * 0.8
	sHigh.Volume = math.clamp((rpmVirtual - 0.4) * 2, 0, 0.8)

	-- 4. VARIACIÓN DE PITCH (Tono)
	local pitchBase = 0.75 + (rpmVirtual * 0.75)
	sLow.PlaybackSpeed = pitchBase
	sMed.PlaybackSpeed = pitchBase
	sHigh.PlaybackSpeed = pitchBase
end)