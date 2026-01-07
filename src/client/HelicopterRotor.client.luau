-- HelicopterRotorClient
-- Colocar en StarterPlayerScripts

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local rotorEvent = ReplicatedStorage:WaitForChild("HelicopteroRotor")

local helicopteros = {}

rotorEvent.OnClientEvent:Connect(function(modelo, velocidad)
    if not modelo or not modelo.Parent then return end
    
    if not helicopteros[modelo] then
        local engine = modelo:FindFirstChild("Engine", true)
        
        if not engine then
            warn("[HeliRotor] No se encontró Engine en:", modelo.Name)
            return
        end
        
        local motor1, motor2
        for _, child in pairs(engine:GetChildren()) do
            if child:IsA("Motor6D") and child.Name == "RotorMotor" then
                if child.Part1 and child.Part1.Name == "Rotor" then
                    motor1 = child
                elseif child.Part1 and child.Part1.Name == "Rotor1" then
                    motor2 = child
                end
            end
        end
        
        helicopteros[modelo] = {
            motorPrincipal = motor1,
            motorCola = motor2,
            velocidad = velocidad,
            angulo = 0
        }
        
        print("[HeliRotor] Registrado:", modelo.Name)
    else
        helicopteros[modelo].velocidad = velocidad
    end
end)

RunService.RenderStepped:Connect(function(deltaTime)
    for modelo, data in pairs(helicopteros) do
        if not modelo or not modelo.Parent then
            helicopteros[modelo] = nil
            continue
        end
        
        data.angulo = data.angulo + (data.velocidad * 15 * deltaTime)
        
        -- Rotor principal (probamos eje Z)
        if data.motorPrincipal then
           data.motorPrincipal.Transform = CFrame.Angles(0, data.angulo, 0)
        end
        
        -- Rotor de cola (eje X funcionaba)
        if data.motorCola then
           data.motorCola.Transform = CFrame.Angles(0,  data.angulo,0)
        end
    end
end)

print("[HeliRotor] Cliente iniciado")