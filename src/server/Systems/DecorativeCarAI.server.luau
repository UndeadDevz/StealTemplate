--[[
	═══════════════════════════════════════════════════════════════════════
	DECORATIVE CAR AI - Sistema de IA para autos decorativos
	═══════════════════════════════════════════════════════════════════════

	INSTRUCCIONES:
	1. Agrega la tag "AutoDecorativo" al modelo que quieras animar
	2. El modelo debe tener un hijo llamado "auto" con las MeshParts
	3. El modelo debe tener un PrimaryPart o un HumanoidRootPart

	═══════════════════════════════════════════════════════════════════════
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")

-- ========== CONFIGURACIÓN ==========
local TAG_NAME = "AutoDecorativo"
local COLLISION_GROUP = "Decorativos"

local TEXTURAS_COCHE = {
	"rbxassetid://82038652466798",
	"rbxassetid://110790282037693",
	"rbxassetid://126479336931992",
	"rbxassetid://135047336608255",
	"rbxassetid://117607448214663"
}

local MAX_JUGADORES = 8
local ALTURA_SALTO = 1.2
local PROBABILIDAD_SALTO = 5
local TIEMPO_MOVIMIENTO = 0.35
-- ===================================

-- Registrar grupo de colisión una sola vez
local function setupCollisionGroup()
	-- Registrar grupo de decorativos
	pcall(function()
		PhysicsService:RegisterCollisionGroup(COLLISION_GROUP)
	end)
	-- Asegurar que el grupo "Players" exista antes de configurar colisión
	pcall(function()
		PhysicsService:RegisterCollisionGroup("Players")
	end)
	-- Configurar que no colisionen entre sí
	pcall(function()
		PhysicsService:CollisionGroupSetCollidable(COLLISION_GROUP, "Players", false)
	end)
end

local function asignarCollisionGroup(modelo)
	for _, parte in pairs(modelo:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.CollisionGroup = COLLISION_GROUP
		end
	end
end

local function aplicarTexturaRandom(modelo, listaIDs)
	if not modelo or #listaIDs == 0 then return end
	local idElegida = listaIDs[math.random(1, #listaIDs)]

	for _, parte in pairs(modelo:GetDescendants()) do
		if parte:IsA("MeshPart") then
			parte.TextureID = idElegida
		elseif parte:IsA("SpecialMesh") then
			parte.TextureId = idElegida
		end
	end
end

local function setVisibilidad(modelo, estado)
	local transparencia = estado and 0 or 1
	for _, parte in pairs(modelo:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.Transparency = transparencia
			parte.CanTouch = estado
			parte.CollisionGroup = COLLISION_GROUP
		elseif parte:IsA("Decal") or parte:IsA("Texture") then
			parte.Transparency = transparencia
		end
	end
end

local function iniciarIA(modeloPrincipal)
	local auto = modeloPrincipal:FindFirstChild("auto")
	local raiz = modeloPrincipal.PrimaryPart or modeloPrincipal:FindFirstChild("HumanoidRootPart", true)

	if not raiz or not auto then
		warn("[DecorativeCarAI] Modelo inválido:", modeloPrincipal.Name, "- Requiere 'auto' y PrimaryPart/HumanoidRootPart")
		return
	end

	local cframeCentro = raiz.CFrame
	local oculto = false

	-- Configurar colisiones y textura inicial
	asignarCollisionGroup(modeloPrincipal)
	aplicarTexturaRandom(auto, TEXTURAS_COCHE)

	print("[DecorativeCarAI] IA iniciada para:", modeloPrincipal.Name)

	while modeloPrincipal.Parent do
		-- Comprobación de jugadores
		local cantidadJugadores = #Players:GetPlayers()

		if cantidadJugadores > MAX_JUGADORES then
			if not oculto then
				setVisibilidad(modeloPrincipal, false)
				oculto = true
			end
			task.wait(5)
			continue
		else
			if oculto then
				aplicarTexturaRandom(auto, TEXTURAS_COCHE)
				setVisibilidad(modeloPrincipal, true)
				oculto = false
				modeloPrincipal:PivotTo(cframeCentro)
			end
		end

		-- Movimiento ambiental
		local anguloPos = math.rad(math.random(0, 360))
		local dist = math.random(10, 20) / 10
		local posRelativa = Vector3.new(math.cos(anguloPos) * dist, 0, math.sin(anguloPos) * dist)

		local esVueltaCompleta = math.random(1, 100) <= 10
		local rotY = esVueltaCompleta and math.rad(360) or math.rad(math.random(-90, 90))

		if math.random(1, 100) <= PROBABILIDAD_SALTO then
			local t = 0.2
			local up = cframeCentro * CFrame.new(posRelativa + Vector3.new(0, ALTURA_SALTO, 0)) * CFrame.Angles(0, rotY, 0)
			local down = cframeCentro * CFrame.new(posRelativa) * CFrame.Angles(0, rotY, 0)

			TweenService:Create(raiz, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = up}):Play()
			task.wait(t)
			TweenService:Create(raiz, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = down}):Play()
			task.wait(t)
		else
			local dest = cframeCentro * CFrame.new(posRelativa) * CFrame.Angles(0, rotY, 0)
			local tween = TweenService:Create(raiz, TweenInfo.new(TIEMPO_MOVIMIENTO, Enum.EasingStyle.Sine), {CFrame = dest})
			tween:Play()
			tween.Completed:Wait()
		end

		task.wait(math.random(5, 15) / 10)
	end
end

-- ========== INICIALIZACIÓN ==========

setupCollisionGroup()

-- Iniciar IA para modelos existentes con la tag
for _, modelo in pairs(CollectionService:GetTagged(TAG_NAME)) do
	task.spawn(iniciarIA, modelo)
end

-- Escuchar nuevos modelos con la tag
CollectionService:GetInstanceAddedSignal(TAG_NAME):Connect(function(modelo)
	task.spawn(iniciarIA, modelo)
end)

print("[DecorativeCarAI] Sistema inicializado - Tag:", TAG_NAME)
