-- HelicopterManager (Server)
-- Colocar en ServerScriptService

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TAG_NAME = "HelicopteroIA"

local rotorEvent = Instance.new("RemoteEvent")
rotorEvent.Name = "HelicopteroRotor"
rotorEvent.Parent = ReplicatedStorage

local CONFIG = {
    MAX_SPEED = 250,
    ALTURA_VUELO = 36,
    DISTANCIA_LASER = 50,
    DANO_POR_SEGUNDO = 40,
    RANGO_DETECCION = 250,
    UPDATE_RATE = 0.3,
    PLAYER_CACHE_RATE = 0.2,
}

local jugadoresActivos = {}
local zonasCache = {}

local function obtenerZona(nombreZona)
    if not nombreZona then return nil end
    if not zonasCache[nombreZona] then
        zonasCache[nombreZona] = workspace:FindFirstChild(nombreZona, true)
    end
    return zonasCache[nombreZona]
end

local function estaDentroDeZona(posicion, zona)
    if not zona then return true end
    local localPos = zona.CFrame:PointToObjectSpace(posicion)
    local s = zona.Size
    return math.abs(localPos.X) <= s.X/2 and 
           math.abs(localPos.Y) <= s.Y/2 and 
           math.abs(localPos.Z) <= s.Z/2
end

task.spawn(function()
    while true do
        local nuevaLista = {}
        for _, jugador in pairs(Players:GetPlayers()) do
            local personaje = jugador.Character
            if personaje then
                local root = personaje:FindFirstChild("HumanoidRootPart")
                local hum = personaje:FindFirstChild("Humanoid")
                if root and hum and hum.Health > 0 then
                    table.insert(nuevaLista, {
                        personaje = personaje,
                        posicion = root.Position,
                        nombre = jugador.Name
                    })
                end
            end
        end
        jugadoresActivos = nuevaLista
        task.wait(CONFIG.PLAYER_CACHE_RATE)
    end
end)

-- ========== CONFIGURAR ROTORES CON MOTOR6D ==========

local function configurarRotorMotor6D(rotorPart, engine)
    if not rotorPart or not engine then return nil end
    
    -- Remover welds existentes del rotor
    for _, child in pairs(rotorPart:GetChildren()) do
        if child:IsA("Weld") or child:IsA("WeldConstraint") then
            child:Destroy()
        end
    end
    
    -- Remover RotateV si existe
    local rotateV = rotorPart:FindFirstChild("RotateV")
    if rotateV then
        rotateV:Destroy()
    end
    
    -- Hacer el rotor no anclado y sin colisión
    rotorPart.Anchored = false
    rotorPart.CanCollide = false
    rotorPart.Massless = true
    
    -- Crear Motor6D
    local motor = Instance.new("Motor6D")
    motor.Name = "RotorMotor"
    motor.Part0 = engine
    motor.Part1 = rotorPart
    motor.C0 = engine.CFrame:ToObjectSpace(rotorPart.CFrame)
    motor.C1 = CFrame.new()
    motor.Parent = engine
    
    print("[HeliManager] Motor6D creado para:", rotorPart.Name)
    
    return motor
end

-- ========== CLASE HELICÓPTERO ==========

local function crearHelicoptero(modelo)
    local self = {}
    
    self.modelo = modelo
    self.engine = modelo:FindFirstChild("Engine", true)
    
    if not self.engine then
        warn("[HeliManager] Helicóptero sin Engine:", modelo:GetFullName())
        return nil
    end
    
    local nombreZona = modelo:GetAttribute("Zona") or "Labyrinth"
    self.zona = obtenerZona(nombreZona)
    
    self.posicionInicial = self.engine.Position
    self.velocidadActual = 0
    self.ultimoDano = {}
    self.activo = true
    self.rotorSpeed = 0
    
    -- ========== CONFIGURAR FÍSICA ==========
    for _, parte in pairs(modelo:GetDescendants()) do
        if parte:IsA("BasePart") then
            if parte ~= self.engine and parte.Name ~= "Rotor" and parte.Name ~= "Rotor1" then
                parte.Massless = true
                
                if not parte.Anchored then
                    local tieneConexion = parte:FindFirstChildOfClass("WeldConstraint") or
                                          parte:FindFirstChildOfClass("Weld") or
                                          parte:FindFirstChildOfClass("Motor6D")
                    
                    if not tieneConexion then
                        local weld = Instance.new("WeldConstraint")
                        weld.Part0 = self.engine
                        weld.Part1 = parte
                        weld.Parent = parte
                    end
                end
            end
        end
    end
    
    -- ========== CONFIGURAR ROTORES ==========
    local rotor = modelo:FindFirstChild("Rotor", true)
    local rotor1 = modelo:FindFirstChild("Rotor1", true)
    
    self.motorRotor = configurarRotorMotor6D(rotor, self.engine)
    self.motorRotor1 = configurarRotorMotor6D(rotor1, self.engine)
    
    -- BodyMovers
    self.gyro = self.engine:FindFirstChild("BodyGyro") or Instance.new("BodyGyro")
    self.gyro.MaxTorque = Vector3.new(1e4, 1e4, 1e4)
    self.gyro.D = 1250
    self.gyro.CFrame = self.engine.CFrame
    self.gyro.Parent = self.engine
    
    self.bodyVelocity = self.engine:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
    self.bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    self.bodyVelocity.Velocity = Vector3.zero
    self.bodyVelocity.Parent = self.engine
    
    -- Rayo láser
    self.rayo = modelo:FindFirstChild("RayoLaser")
    if not self.rayo then
        self.rayo = Instance.new("Part")
        self.rayo.Name = "RayoLaser"
        self.rayo.Anchored = true
        self.rayo.CanCollide = false
        self.rayo.Material = Enum.Material.Neon
        self.rayo.Color = Color3.fromRGB(255, 0, 0)
        self.rayo.Transparency = 1
        self.rayo.CastShadow = false
        self.rayo.Parent = modelo
    end
    
    -- ========== MÉTODOS ==========
    
    function self:setRotorSpeed(velocidad)
        if self.rotorSpeed ~= velocidad then
            self.rotorSpeed = velocidad
            rotorEvent:FireAllClients(self.modelo, velocidad)
        end
    end
    
    function self:actualizarRayo(desde, hasta, activo)
        if activo and hasta then
            local distancia = (hasta - desde).Magnitude
            local medio = (desde + hasta) / 2
            self.rayo.Size = Vector3.new(0.5, 0.5, distancia)
            self.rayo.CFrame = CFrame.new(medio, hasta)
            self.rayo.Transparency = 0.3
        else
            self.rayo.Transparency = 1
        end
    end
    
    function self:encontrarObjetivo()
        local objetivoCercano = nil
        local distanciaMinima = CONFIG.RANGO_DETECCION
        local posEngine = self.engine.Position
        
        for _, datos in pairs(jugadoresActivos) do
            if estaDentroDeZona(datos.posicion, self.zona) then
                local distancia = (datos.posicion - posEngine).Magnitude
                if distancia < distanciaMinima then
                    distanciaMinima = distancia
                    objetivoCercano = datos
                end
            end
        end
        
        return objetivoCercano, distanciaMinima
    end
    
    function self:hacerDano(datosJugador, distancia)
        if distancia > CONFIG.DISTANCIA_LASER then
            self:actualizarRayo(nil, nil, false)
            return false
        end
        
        local personaje = datosJugador.personaje
        local humanoide = personaje:FindFirstChild("Humanoid")
        
        if not humanoide or humanoide.Health <= 0 then
            self:actualizarRayo(nil, nil, false)
            return false
        end
        
        local tiempoActual = tick()
        local nombre = datosJugador.nombre
        
        if not self.ultimoDano[nombre] or (tiempoActual - self.ultimoDano[nombre]) >= 1 then
            humanoide:TakeDamage(CONFIG.DANO_POR_SEGUNDO)
            self.ultimoDano[nombre] = tiempoActual
            
            self.rayo.Color = Color3.fromRGB(255, 255, 255)
            task.delay(0.1, function()
                if self.rayo then
                    self.rayo.Color = Color3.fromRGB(255, 0, 0)
                end
            end)
        end
        
        local rootPart = personaje:FindFirstChild("HumanoidRootPart")
        if rootPart then
            self:actualizarRayo(self.engine.Position, rootPart.Position, true)
        end
        
        return true
    end
    
    function self:update()
        if not self.activo or not self.engine.Parent then
            return false
        end
        
        local objetivo, distancia = self:encontrarObjetivo()
        
        if objetivo then
            local posJugador = objetivo.posicion
            local posObjetivo = posJugador + Vector3.new(0, CONFIG.ALTURA_VUELO, 0)
            local direccion = (posObjetivo - self.engine.Position).Unit
            
            self:setRotorSpeed(0.6)
            
            local chgY = (posObjetivo.Y - self.engine.Position.Y) * 1.2
            local distH = (Vector2.new(posJugador.X, posJugador.Z) - 
                          Vector2.new(self.engine.Position.X, self.engine.Position.Z)).Magnitude
            
            if distH > 5 then
                self.velocidadActual = math.min(self.velocidadActual + 8, CONFIG.MAX_SPEED)
            else
                self.velocidadActual = self.velocidadActual * 0.95
            end
            
            self.bodyVelocity.Velocity = (direccion * self.velocidadActual) + Vector3.new(0, chgY, 0)
            self.gyro.CFrame = CFrame.new(self.engine.Position, 
                Vector3.new(posJugador.X, self.engine.Position.Y, posJugador.Z))
            
            self:hacerDano(objetivo, distancia)
        else
            self:actualizarRayo(nil, nil, false)
            self:setRotorSpeed(0.3)
            self.velocidadActual = self.velocidadActual * 0.9
            
            local distBase = (self.engine.Position - self.posicionInicial).Magnitude
            if distBase > 5 then
                local dirBase = (self.posicionInicial - self.engine.Position).Unit
                self.bodyVelocity.Velocity = dirBase * 20
                self.gyro.CFrame = CFrame.new(self.engine.Position, self.posicionInicial)
            else
                self.bodyVelocity.Velocity = Vector3.new(0, math.sin(tick()) * 1, 0)
            end
        end
        
        return true
    end
    
    function self:destruir()
        self.activo = false
        self:setRotorSpeed(0)
    end
    
    self:setRotorSpeed(0.3)
    
    return self
end

-- ========== MANAGER ==========

local helicopteros = {}

local function registrarHelicoptero(modelo)
    if helicopteros[modelo] then return end
    
    local heli = crearHelicoptero(modelo)
    if heli then
        helicopteros[modelo] = heli
        print("[HeliManager] Registrado:", modelo:GetFullName())
    end
end

local function removerHelicoptero(modelo)
    local heli = helicopteros[modelo]
    if heli then
        heli:destruir()
        helicopteros[modelo] = nil
    end
end

for _, modelo in pairs(CollectionService:GetTagged(TAG_NAME)) do
    registrarHelicoptero(modelo)
end

CollectionService:GetInstanceAddedSignal(TAG_NAME):Connect(registrarHelicoptero)
CollectionService:GetInstanceRemovedSignal(TAG_NAME):Connect(removerHelicoptero)

task.spawn(function()
    while true do
        for modelo, heli in pairs(helicopteros) do
            if not heli:update() then
                helicopteros[modelo] = nil
            end
        end
        task.wait(CONFIG.UPDATE_RATE)
    end
end)

print("[HeliManager] Servidor iniciado")