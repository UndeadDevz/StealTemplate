local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local Workspace = game:GetService("Workspace")

local TAG_NAME = "PoliciaNPC"
local ZONA = Workspace:WaitForChild("GetOverHere")
local VELOCIDAD = 32
local DISTANCIA_MATAR = 15 -- Distancia en studs para matar al jugador
local COLLISION_GROUP = "PoliciaNPC"

-- Configurar grupo de colisión para que no empujen a jugadores
pcall(function()
    PhysicsService:RegisterCollisionGroup(COLLISION_GROUP)
end)
pcall(function()
    PhysicsService:CollisionGroupSetCollidable(COLLISION_GROUP, "Players", false)
end)

-- OPTIMIZACIÓN 1: Cache de jugadores en zona (evita recalcular cada frame)
local jugadoresEnZona = {}

local function estaDentroDeZona(posicion)
    local cf = ZONA.CFrame
    local size = ZONA.Size / 2
    local posicionLocal = cf:PointToObjectSpace(posicion)
    return math.abs(posicionLocal.X) <= size.X and math.abs(posicionLocal.Z) <= size.Z
end

-- Actualizar cache de jugadores periódicamente (NO cada NPC)
task.spawn(function()
    while true do
        local nuevaLista = {}
        for _, jugador in pairs(Players:GetPlayers()) do
            local personaje = jugador.Character
            if personaje and personaje:FindFirstChild("HumanoidRootPart") then
                if estaDentroDeZona(personaje.HumanoidRootPart.Position) then
                    table.insert(nuevaLista, personaje)
                end
            end
        end
        jugadoresEnZona = nuevaLista
        task.wait(0.2) -- Actualiza 5 veces por segundo, suficiente
    end
end)

local function asignarCollisionGroup(npc)
    for _, parte in pairs(npc:GetDescendants()) do
        if parte:IsA("BasePart") then
            parte.CollisionGroup = COLLISION_GROUP
        end
    end
end

local function configurarPolicia(npc)
    local humanoid = npc:WaitForChild("Humanoid", 5)
    local rootPart = npc:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not rootPart then return end

    humanoid.WalkSpeed = VELOCIDAD
    local posicionInicial = rootPart.Position

    -- Asignar collision group para no empujar jugadores
    asignarCollisionGroup(npc)

    -- Debounce para evitar matar al mismo jugador varias veces
    local jugadoresGolpeados = {}

    -- IA usa el cache global + detección por distancia
    task.spawn(function()
        while npc.Parent and humanoid.Health > 0 do
            local jugadorCercano = nil
            local distanciaMinima = math.huge

            -- Usa el cache en lugar de recalcular
            for _, personaje in pairs(jugadoresEnZona) do
                local hrp = personaje:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distancia = (hrp.Position - rootPart.Position).Magnitude
                    if distancia < distanciaMinima then
                        distanciaMinima = distancia
                        jugadorCercano = personaje
                    end
                end
            end

            if jugadorCercano then
                local hrp = jugadorCercano:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Mover hacia el jugador
                    humanoid:MoveTo(hrp.Position)

                    -- Detectar por distancia y matar
                    if distanciaMinima <= DISTANCIA_MATAR then
                        local jugador = Players:GetPlayerFromCharacter(jugadorCercano)
                        if jugador and not jugadoresGolpeados[jugador] then
                            jugadoresGolpeados[jugador] = true

                            local humanoide = jugadorCercano:FindFirstChild("Humanoid")
                            if humanoide and humanoide.Health > 0 then
                                humanoide.Health = 0
                            end

                            -- Limpiar debounce después de un tiempo
                            task.delay(1, function()
                                jugadoresGolpeados[jugador] = nil
                            end)
                        end
                    end
                end
            elseif (rootPart.Position - posicionInicial).Magnitude > 5 then
                humanoid:MoveTo(posicionInicial)
            end

            task.wait(0.15) -- Más frecuente para mejor detección
        end
    end)
end

for _, npc in pairs(CollectionService:GetTagged(TAG_NAME)) do
    configurarPolicia(npc)
end

CollectionService:GetInstanceAddedSignal(TAG_NAME):Connect(configurarPolicia)