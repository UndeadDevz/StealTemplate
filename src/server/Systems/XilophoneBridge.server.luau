--[[
	XilophoneBridge.server.luau
	Controla el puente Xilophone con efecto de desaparición/aparición en cadena
]]

local TweenService = game:GetService("TweenService")

-- Configuración
local FADE_DURATION = 0.3 -- Duración del tween de cada pieza
local DELAY_BETWEEN_PIECES = 0.15 -- Delay entre cada pieza
local TIME_HIDDEN = 1 -- Tiempo que permanecen ocultas
local TIME_VISIBLE = 2 -- Tiempo que permanecen visibles antes de desaparecer
local CYCLE_ENABLED = true -- Si el ciclo se repite

-- Configuración de sonido
local SOUND_ID = "rbxassetid://94691316149771" -- C3 xilófono
local SOUND_VOLUME = 0.5

-- Escala mayor: semitonos desde C (Do Re Mi Fa Sol La Si)
-- Para 18 notas: 2 octavas completas + 4 notas
local SCALE_SEMITONES = {
	0,  -- C3 (Do)
	2,  -- D3 (Re)
	4,  -- E3 (Mi)
	5,  -- F3 (Fa)
	7,  -- G3 (Sol)
	9,  -- A3 (La)
	11, -- B3 (Si)
	12, -- C4 (Do)
	14, -- D4 (Re)
	16, -- E4 (Mi)
	17, -- F4 (Fa)
	19, -- G4 (Sol)
	21, -- A4 (La)
	23, -- B4 (Si)
	24, -- C5 (Do)
	26, -- D5 (Re)
	28, -- E5 (Mi)
	29, -- F5 (Fa)
}

-- Función para calcular el pitch desde semitonos
local function semitoneToPitch(semitone)
	return 2 ^ (semitone / 12)
end

-- Buscar el modelo Xilophone
local xilophone = workspace:WaitForChild("Xilophone", 10)
if not xilophone then
	warn("[XilophoneBridge] No se encontró el modelo 'Xilophone' en workspace")
	return
end

-- Recolectar y ordenar las piezas
local pieces = {}
for _, child in pairs(xilophone:GetChildren()) do
	if child:IsA("Model") and child.Name:match("^XilophonePiece") then
		-- Extraer el número de la pieza
		local pieceNumber = tonumber(child.Name:match("%d+"))
		if pieceNumber then
			table.insert(pieces, {
				model = child,
				number = pieceNumber,
				rectangle = child:FindFirstChild("rectangle")
			})
		end
	end
end

-- Ordenar por número
table.sort(pieces, function(a, b)
	return a.number < b.number
end)

print("[XilophoneBridge] Encontradas " .. #pieces .. " piezas")

if #pieces == 0 then
	warn("[XilophoneBridge] No se encontraron piezas XilophonePiece")
	return
end

-- Crear sonidos para cada pieza
for i, pieceData in ipairs(pieces) do
	if pieceData.rectangle then
		local sound = Instance.new("Sound")
		sound.Name = "XilophoneSound"
		sound.SoundId = SOUND_ID
		sound.Volume = SOUND_VOLUME
		sound.PlaybackSpeed = semitoneToPitch(SCALE_SEMITONES[i] or 0)
		sound.Parent = pieceData.rectangle
		pieceData.sound = sound
	end
end

print("[XilophoneBridge] Sonidos creados con escala mayor")

-- Tween info para fade
local fadeOutInfo = TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local fadeInInfo = TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

-- Función para desvanecer una parte y sus texturas
local function fadeOut(part, sound)
	if not part then return end

	-- Reproducir sonido al iniciar el desvanecido
	if sound then
		sound:Play()
	end

	local tweens = {}

	-- Fade de la parte principal
	local partTween = TweenService:Create(part, fadeOutInfo, {Transparency = 1})
	table.insert(tweens, partTween)

	-- Fade de todas las texturas/decals dentro de la parte
	for _, child in pairs(part:GetDescendants()) do
		if child:IsA("Texture") or child:IsA("Decal") then
			local textureTween = TweenService:Create(child, fadeOutInfo, {Transparency = 1})
			table.insert(tweens, textureTween)
		end
	end

	-- Iniciar todos los tweens
	for _, tween in pairs(tweens) do
		tween:Play()
	end

	-- Esperar a que termine el tween principal
	tweens[1].Completed:Wait()

	-- Desactivar colisión después del fade
	part.CanCollide = false
end

-- Función para hacer aparecer una parte y sus texturas
local function fadeIn(part, sound)
	if not part then return end

	-- Reproducir sonido al iniciar la aparición
	if sound then
		sound:Play()
	end

	-- Activar colisión primero
	part.CanCollide = true

	local tweens = {}

	-- Fade de la parte principal
	local partTween = TweenService:Create(part, fadeInInfo, {Transparency = 0})
	table.insert(tweens, partTween)

	-- Fade de todas las texturas/decals dentro de la parte
	for _, child in pairs(part:GetDescendants()) do
		if child:IsA("Texture") or child:IsA("Decal") then
			local textureTween = TweenService:Create(child, fadeInInfo, {Transparency = 0})
			table.insert(tweens, textureTween)
		end
	end

	-- Iniciar todos los tweens
	for _, tween in pairs(tweens) do
		tween:Play()
	end

	-- Esperar a que termine el tween principal
	tweens[1].Completed:Wait()
end

-- Función para desaparecer todas las piezas en secuencia (1 → 18)
local function disappearSequence()
	for i, pieceData in ipairs(pieces) do
		task.spawn(function()
			fadeOut(pieceData.rectangle, pieceData.sound)
		end)
		if i < #pieces then
			task.wait(DELAY_BETWEEN_PIECES)
		end
	end
	-- Esperar a que termine la última
	task.wait(FADE_DURATION)
end

-- Función para aparecer todas las piezas en secuencia inversa (18 → 1)
local function appearSequence()
	for i = #pieces, 1, -1 do
		local pieceData = pieces[i]
		task.spawn(function()
			fadeIn(pieceData.rectangle, pieceData.sound)
		end)
		if i > 1 then
			task.wait(DELAY_BETWEEN_PIECES)
		end
	end
	-- Esperar a que termine la última
	task.wait(FADE_DURATION)
end

-- Ciclo principal
task.spawn(function()
	-- Asegurar que todas las piezas empiecen visibles
	for _, pieceData in ipairs(pieces) do
		if pieceData.rectangle then
			pieceData.rectangle.Transparency = 0
			pieceData.rectangle.CanCollide = true
			for _, child in pairs(pieceData.rectangle:GetDescendants()) do
				if child:IsA("Texture") or child:IsA("Decal") then
					child.Transparency = 0
				end
			end
		end
	end

	while CYCLE_ENABLED do
		-- Esperar tiempo visible
		task.wait(TIME_VISIBLE)

		-- Desaparecer en secuencia
		print("[XilophoneBridge] Desapareciendo piezas...")
		disappearSequence()

		-- Esperar tiempo oculto
		task.wait(TIME_HIDDEN)

		-- Aparecer en secuencia
		print("[XilophoneBridge] Apareciendo piezas...")
		appearSequence()
	end
end)

print("[XilophoneBridge] Sistema inicializado")
