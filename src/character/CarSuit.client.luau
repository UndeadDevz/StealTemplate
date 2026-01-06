-- LocalScript "CarSuit" en StarterCharacterScripts
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local lowerTorso = character:WaitForChild("LowerTorso")

-- ========== CONFIGURACIÓN ==========
local NOMBRE_COCHE = "CocheMesh"
local ANGULO_GIRO_VOLANTE = 45
local VELOCIDAD_GIRO = 10

-- Animaciones
local ANIM_IDLE = "rbxassetid://72471066577154"
local ANIM_LEFT = "rbxassetid://136541988317425"
local ANIM_RIGHT = "rbxassetid://88962280420603"

-- Configuración del Raycast para rampas
local RAYCAST_DISTANCIA = 10
local VELOCIDAD_INCLINACION = 8
local PITCH_MAXIMO = math.rad(35)
-- ===================================

-- Calcular offset de altura una sola vez
local offsetY = -humanoid.HipHeight + (lowerTorso.Size.Y / 2)

-- ========== OCULTAR PERSONAJE REAL ==========
local function ocultarPersonajeReal()
	for _, parte in pairs(character:GetDescendants()) do
		if parte:IsA("BasePart") and parte.Name ~= "HumanoidRootPart" then
			parte.Transparency = 1
		elseif parte:IsA("Decal") or parte:IsA("Texture") then
			parte.Transparency = 1
		elseif parte:IsA("Accessory") then
			local handle = parte:FindFirstChild("Handle")
			if handle then
				handle.Transparency = 1
			end
		end
	end
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
local carroceria = coche.PrimaryPart or coche:FindFirstChildWhichIsA("BasePart")
for _, parte in pairs(coche:GetDescendants()) do
	if parte:IsA("BasePart") then
		parte.CanCollide = false
		parte.Anchored = false
	end
end

carroceria.Anchored = true

-- Buscar conductor y volante
local conductor = coche:WaitForChild("Conductor")
local conductorHumanoid = conductor:WaitForChild("Humanoid")
conductorHumanoid.PlatformStand = true
local conductorAnimator = conductorHumanoid:WaitForChild("Animator")
local volante = coche:WaitForChild("Volante")

-- Guardar offset del volante respecto al coche
local volanteOffset = carroceria.CFrame:ToObjectSpace(volante.CFrame)

-- Motor6D para el volante
local motorVolante = Instance.new("Motor6D")
motorVolante.Name = "VolanteMotor"
motorVolante.Part0 = carroceria
motorVolante.Part1 = volante
motorVolante.C0 = volanteOffset
motorVolante.Parent = carroceria

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
		local diferencia = rayFrente.Position.Y - rayAtras.Position.Y
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
	motorVolante.C0 = volanteOffset * CFrame.Angles(0, math.rad(anguloActual), 0)

	local pitchObjetivo = obtenerPitchSuelo()
	pitchActual = pitchActual + (pitchObjetivo - pitchActual) * dt * VELOCIDAD_INCLINACION

	local rotacionBase = rootPart.CFrame - rootPart.Position
	local inclinacion = CFrame.Angles(pitchActual, 0, 0)

	carroceria.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, offsetY, 0)) * rotacionBase * inclinacion
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

print("Car-Suit listo!")