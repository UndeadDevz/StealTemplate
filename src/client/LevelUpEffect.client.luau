--[[
	═══════════════════════════════════════════════════════════════════════
	EFECTO VISUAL DE SUBIDA DE NIVEL - CLIENTE
	═══════════════════════════════════════════════════════════════════════
	
	Este LocalScript escucha cuando CUALQUIER jugador sube de nivel
	y muestra el efecto de partículas.
	
	INSTRUCCIONES DE CONFIGURACIÓN:
	1. En ReplicatedStorage, crea una carpeta llamada "Effects"
	2. Crea una Part invisible llamada "LevelUpEffect" con estas propiedades:
	   - Transparency = 1
	   - CanCollide = false
	   - Anchored = false
	   - Size = Vector3.new(1, 1, 1)
	
	3. Dentro de "LevelUpEffect", crea un Attachment
	4. Dentro del Attachment, agrega tus ParticleEmitters con:
	   - Enabled = false (importante, para que no emitan desde el inicio)
	   - Rate = El rate que quieras (ejemplo: 20, 50, 100)
	   - Lifetime = Cuánto duran las partículas (ejemplo: 1-2 segundos)
	
	5. SONIDO: En ReplicatedStorage > Effects, crea un Sound llamado "LevelUpSound"
	   - SoundId = ID de tu sonido favorito
	   - Volume = 0.5 (ajusta según prefieras)
	
	═══════════════════════════════════════════════════════════════════════
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- ══════════════════════════════════════════════════════════════════════
-- CONFIGURACIÓN
-- ══════════════════════════════════════════════════════════════════════
local DURACION_EFECTO = 2 -- Segundos que las partículas están activas

-- ══════════════════════════════════════════════════════════════════════

-- Esperar al RemoteEvent
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local efectoLvlUp = remoteEventsFolder:WaitForChild("EfectoLvlUp")

-- Buscar el efecto de partículas y sonido
local effectsFolder = ReplicatedStorage:FindFirstChild("Effects")
local efectoOriginal = effectsFolder and effectsFolder:FindFirstChild("LevelUpEffect")
local sonidoOriginal = effectsFolder and effectsFolder:FindFirstChild("LevelUpSound")

-- Función para activar partículas temporalmente
local function activarParticulas(particula)
	if not particula:IsA("ParticleEmitter") then return end
	
	particula.Enabled = true
	
	-- Desactivar después de la duración configurada
	task.delay(DURACION_EFECTO, function()
		particula.Enabled = false
	end)
end

-- Evento cuando alguien sube de nivel
efectoLvlUp.OnClientEvent:Connect(function(personaje, nuevoNivel)
	-- Validar que el personaje existe
	if not personaje or not personaje:IsA("Model") then return end
	
	local root = personaje:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	-- REPRODUCIR SONIDO
	if sonidoOriginal and sonidoOriginal:IsA("Sound") then
		local sonidoClon = sonidoOriginal:Clone()
		sonidoClon.Parent = root
		sonidoClon:Play()
		Debris:AddItem(sonidoClon, sonidoClon.TimeLength + 0.1)
	end
	
	-- Si no hay efecto configurado, solo mostrar mensaje en consola
	if not efectoOriginal then
		print("⭐ " .. personaje.Name .. " subió al nivel " .. nuevoNivel .. "!")
		return
	end
	
	-- Clonar el efecto localmente
	local clon = efectoOriginal:Clone()
	clon.Parent = root
	
	-- Ajustar posición y anclar al personaje
	if clon:IsA("BasePart") then
		clon.CFrame = root.CFrame
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = clon
		weld.Part1 = root
		weld.Parent = clon
	end
	
	-- ACTIVAR LAS PARTÍCULAS
	-- 1. Las partículas dentro del Attachment
	local attach = clon:FindFirstChildWhichIsA("Attachment")
	if attach then
		for _, hijo in pairs(attach:GetChildren()) do
			activarParticulas(hijo)
		end
	end
	
	-- 2. Las partículas que están directamente en el objeto
	for _, hijo in pairs(clon:GetChildren()) do
		activarParticulas(hijo)
	end
	
	-- Mostrar mensaje en consola
	print("⭐ " .. personaje.Name .. " subió al nivel " .. nuevoNivel .. "!")
	
	-- Limpiar el efecto después del lifetime máximo de las partículas + duración
	Debris:AddItem(clon, DURACION_EFECTO + 3)
end)
