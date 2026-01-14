local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

-- Referencias a tu sistema de coches
local grantCarsuit = ServerScriptService.Systems.CarsuitShopHandler:WaitForChild("GrantCarsuit")
local SHARK_CAR_ID = 9 

-- Referencia al modelo (Debe estar en ServerStorage inicialmente)
local islaOriginal = ServerStorage:WaitForChild("SharkEventPlace")
local islaEnMapa = nil -- Variable para rastrear la isla cuando esté en el Workspace

-- Función para verificar si es fin de semana (UTC)
local function isWeekend()
    local date = os.date("!*t")
    local day = date.wday
    -- 6: Viernes, 7: Sábado, 1: Domingo
    return (day == 6 or day == 7 or day == 1)
end

local function gestionarIsla()
    local activo = isWeekend()

    if activo and not islaEnMapa then
        -- ACTIVAR: Clonamos la isla de ServerStorage al Workspace
        islaEnMapa = islaOriginal:Clone()
        islaEnMapa.Parent = Workspace
        
        -- Configurar el ProximityPrompt dentro de la isla clonada
        local prompt = islaEnMapa:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            prompt.Triggered:Connect(function(player)
                local result = grantCarsuit:Invoke(player, SHARK_CAR_ID)
                if result.success then
                    print(player.Name .. " obtuvo el coche tiburón!")
                end
            end)
        end
        print("--- La Isla del Tiburón ha aparecido ---")

    elseif not activo and islaEnMapa then
        -- DESACTIVAR: Eliminamos la isla del mapa
        islaEnMapa:Destroy()
        islaEnMapa = nil
        print("--- La Isla del Tiburón ha desaparecido ---")
    end
end

-- Bucle de revisión (cada 5 minutos para no saturar)
task.spawn(function()
    while true do
        gestionarIsla()
        task.wait(300) 
    end
end)

-- Ejecutar una vez al iniciar el servidor
gestionarIsla()