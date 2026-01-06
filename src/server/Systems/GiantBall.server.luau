local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

-- --- CONFIGURACIÓN ---
local INTERVALO_SPAWN = 4 -- Segundos entre cada bola
local VELOCIDAD_INICIAL = 200 -- Fuerza de empuje inicial (si el camino no es muy inclinado)
local TIEMPO_VIDA_MAX = 20 -- Tiempo máximo antes de borrar la bola si se queda atascada

-- --- REFERENCIAS ---
-- Ajusta las rutas según donde hayas puesto tus partes
local carpetaTrampa = workspace:WaitForChild("TrampaBola") 
local spawner = carpetaTrampa:WaitForChild("SpawnerPart")
local endPoint = carpetaTrampa:WaitForChild("EndPoint")
local bolaTemplate = ServerStorage:WaitForChild("GiantBall") -- La bola guardada

-- --- BUCLE PRINCIPAL ---
while true do
	-- 1. Clonar la bola
    print('Info', spawner,endPoint, bolaTemplate)
	local bola = bolaTemplate:Clone()
	bola.Position = spawner.Position + Vector3.new(0, 5, 0) -- Aparece un poco arriba del spawner
	bola.Parent = workspace
	bola.Anchored = false
	
	-- 2. Dar empuje inicial (Opcional: Si el camino tiene bajada, la gravedad lo hará sola)
	-- Usamos la dirección hacia donde mira el Spawner (LookVector)
	bola.AssemblyLinearVelocity = spawner.CFrame.LookVector * VELOCIDAD_INICIAL
	
	-- 3. Función de contacto
	local conexion
	conexion = bola.Touched:Connect(function(hit)
		-- A) Si toca al jugador: MATAR
		local character = hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0 -- Esto disparará tu DeathHandler automáticamente
			print("💀 Jugador aplastado por la bola")
		end
		
		-- B) Si toca el final del camino: DESAPARECER
		if hit == endPoint then
			print("🗑️ Bola llegó al final, eliminando...")
			conexion:Disconnect() -- Desconectar evento para ahorrar memoria
			bola:Destroy()
		end
	end)
	
	-- 4. Limpieza de seguridad (por si la bola se cae del mapa y no toca el final)
	Debris:AddItem(bola, TIEMPO_VIDA_MAX)
	
	-- Esperar para la siguiente bola
	task.wait(INTERVALO_SPAWN)
end