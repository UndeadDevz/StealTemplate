local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local TAG_NAME = "PoliciaNPC"
local ZONA = Workspace:WaitForChild("GetOverHere")
local VELOCIDAD = 32

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

local function configurarPolicia(npc)
    local humanoid = npc:WaitForChild("Humanoid", 5)
    local rootPart = npc:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not rootPart then return end

    humanoid.WalkSpeed = VELOCIDAD
    local posicionInicial = rootPart.Position

    -- OPTIMIZACIÓN 2: Una sola hitbox en lugar de todas las partes
    local hitbox = npc:FindFirstChild("HitBox") or rootPart
    
    -- OPTIMIZACIÓN 3: Debounce para evitar spam de Touched
    local jugadoresGolpeados = {}
    
    hitbox.Touched:Connect(function(hit)
        local character = hit.Parent
        local jugador = Players:GetPlayerFromCharacter(character)
        
        if jugador and not jugadoresGolpeados[jugador] then
            jugadoresGolpeados[jugador] = true
            
            local humanoide = character:FindFirstChild("Humanoid")
            if humanoide and humanoide.Health > 0 then
                humanoide.Health = 0
            end
            
            -- Limpiar debounce después de un tiempo
            task.delay(1, function()
                jugadoresGolpeados[jugador] = nil
            end)
        end
    end)

    -- OPTIMIZACIÓN 4: IA usa el cache global
    task.spawn(function()
        while npc.Parent and humanoid.Health > 0 do
            local jugadorCercano = nil
            local distanciaMinima = math.huge

            -- Usa el cache en lugar de recalcular
            for _, personaje in pairs(jugadoresEnZona) do
                if personaje:FindFirstChild("HumanoidRootPart") then
                    local distancia = (personaje.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    if distancia < distanciaMinima then
                        distanciaMinima = distancia
                        jugadorCercano = personaje
                    end
                end
            end

            if jugadorCercano and jugadorCercano:FindFirstChild("HumanoidRootPart") then
                humanoid:MoveTo(jugadorCercano.HumanoidRootPart.Position)
            elseif (rootPart.Position - posicionInicial).Magnitude > 5 then
                humanoid:MoveTo(posicionInicial)
            end

            task.wait(0.3) -- Un poco más frecuente para mejor respuesta
        end
    end)
end

for _, npc in pairs(CollectionService:GetTagged(TAG_NAME)) do
    configurarPolicia(npc)
end

CollectionService:GetInstanceAddedSignal(TAG_NAME):Connect(configurarPolicia)