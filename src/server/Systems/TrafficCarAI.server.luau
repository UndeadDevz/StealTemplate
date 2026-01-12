--[[
	═══════════════════════════════════════════════════════════════════════
	TRAFFIC CAR AI - Sistema de IA para autos que avanzan (tráfico)
	═══════════════════════════════════════════════════════════════════════

	INSTRUCCIONES:
	1. Agrega la tag "AutoTrafico" al modelo que quieras animar
	2. El modelo debe tener un hijo llamado "auto" con las MeshParts
	3. El modelo debe tener un PrimaryPart o un HumanoidRootPart
	4. OBLIGATORIO: Agrega el atributo "Delay" (number) para el retraso inicial

	═══════════════════════════════════════════════════════════════════════
]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")

-- ========== CONFIGURACIÓN ==========
local TAG_NAME = "AutoTrafico"
local COLLISION_GROUP = "Decorativos"

local TEXTURAS_COCHE = {
	"rbxassetid://82038652466798",
	"rbxassetid://110790282037693",
	"rbxassetid://126479336931992",
	"rbxassetid://135047336608255",
	"rbxassetid://117607448214663"
}

local VELOCIDAD_MIN = 30
local VELOCIDAD_MAX = 170
local DISTANCIA = 1300
local TIEMPO_ESPERA = 1
local MAX_JUGADORES = 8
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
	if not modelo or #listaIDs == 0 then return "" end
	local idElegida = listaIDs[math.random(1, #listaIDs)]

	for _, parte in pairs(modelo:GetDescendants()) do
		if parte:IsA("MeshPart") then
			parte.TextureID = idElegida
		elseif parte:IsA("SpecialMesh") then
			parte.TextureId = idElegida
		end
	end

	return idElegida
end

local function ocultarCoche(modelo, ocultar)
	for _, parte in pairs(modelo:GetDescendants()) do
		if parte:IsA("BasePart") then
			parte.Transparency = ocultar and 1 or 0
			parte.CanCollide = not ocultar
			parte.CollisionGroup = COLLISION_GROUP
		end
	end
end

local function demasiadosJugadores()
	return #Players:GetPlayers() > MAX_JUGADORES
end

local function iniciarIA(modeloPrincipal)
	local auto = modeloPrincipal:FindFirstChild("auto")
	local raiz = modeloPrincipal.PrimaryPart or modeloPrincipal:FindFirstChild("HumanoidRootPart", true)

	-- Verificar atributo Delay obligatorio
	local delay = modeloPrincipal:GetAttribute("Delay")
	if delay == nil then
		warn("[TrafficCarAI] Modelo sin atributo 'Delay':", modeloPrincipal.Name, "- Atributo obligatorio")
		return
	end

	if not raiz or not auto then
		warn("[TrafficCarAI] Modelo inválido:", modeloPrincipal.Name, "- Requiere 'auto' y PrimaryPart/HumanoidRootPart")
		return
	end

	-- Configurar colisiones
	asignarCollisionGroup(modeloPrincipal)

	local cframeInicial = raiz.CFrame
	local cframeFinal = cframeInicial * CFrame.new(0, 0, -DISTANCIA)

	-- Esperar el delay antes de iniciar
	if delay > 0 then
		task.wait(delay)
	end

	print("[TrafficCarAI] IA iniciada para:", modeloPrincipal.Name, "- Delay:", delay)

	while modeloPrincipal.Parent do
		-- Verificar si hay demasiados jugadores
		if demasiadosJugadores() then
			ocultarCoche(modeloPrincipal, true)

			-- Esperar hasta que bajen los jugadores
			while demasiadosJugadores() do
				task.wait(2)
			end
		end

		-- Resetear posición y mostrar
		ocultarCoche(modeloPrincipal, false)
		modeloPrincipal:PivotTo(cframeInicial)
		aplicarTexturaRandom(auto, TEXTURAS_COCHE)

		-- Calcular velocidad y tiempo de viaje
		local velocidadAleatoria = math.random(VELOCIDAD_MIN, VELOCIDAD_MAX)
		local tiempoDeViaje = DISTANCIA / velocidadAleatoria

		-- Crear y ejecutar el tween
		local info = TweenInfo.new(tiempoDeViaje, Enum.EasingStyle.Linear)
		local movimiento = TweenService:Create(raiz, info, {CFrame = cframeFinal})

		movimiento:Play()
		movimiento.Completed:Wait()

		task.wait(TIEMPO_ESPERA)
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

print("[TrafficCarAI] Sistema inicializado - Tag:", TAG_NAME, "- Requiere atributo 'Delay'")
