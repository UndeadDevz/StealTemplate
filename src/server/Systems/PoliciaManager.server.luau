local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local TAG_NAME = "PoliciaNPC"
local ZONA = Workspace:WaitForChild("GetOverHere")

-- Configuración
local VELOCIDAD = 32

-- Función auxiliar: Verifica si una posición está dentro de la zona
local function estaDentroDeZona(posicion)
	local cf = ZONA.CFrame
	local size = ZONA.Size / 2
	local posicionLocal = cf:PointToObjectSpace(posicion)

	local dentroX = math.abs(posicionLocal.X) <= size.X
	local dentroZ = math.abs(posicionLocal.Z) <= size.Z

	return dentroX and dentroZ
end

local function configurarPolicia(npc)
	local humanoid = npc:WaitForChild("Humanoid", 5)
	local rootPart = npc:WaitForChild("HumanoidRootPart", 5)

	if not humanoid or not rootPart then return end

	humanoid.WalkSpeed = VELOCIDAD
	local posicionInicial = rootPart.Position

	-- 1. Configurar KillZone (CORREGIDO)
	for _, parte in pairs(npc:GetDescendants()) do
		if parte:IsA("BasePart") then
			
				
				parte.Touched:Connect(function(hit)
					local character = hit.Parent
					
					-- VERIFICACIÓN CLAVE:
					-- Intentamos obtener el Jugador asociado al personaje que tocó
					local esJugador = Players:GetPlayerFromCharacter(character)
					print('esJugador', esJugador)
					-- Solo matamos si 'esJugador' NO es nil (es decir, es una persona real)
					if esJugador then
						local humanoideObjetivo = character:FindFirstChild("Humanoid")
						if humanoideObjetivo and humanoideObjetivo.Health > 0 then
							humanoideObjetivo.Health = 0
						end
					end
				end)
				
			
		end
	end

	-- 2. IA de Persecución
	task.spawn(function()
		while npc.Parent and humanoid.Health > 0 do
			
			local jugadorCercano = nil
			local distanciaMinima = math.huge

			for _, jugador in pairs(Players:GetPlayers()) do
				local personaje = jugador.Character
				if personaje and personaje:FindFirstChild("HumanoidRootPart") then
					local posJugador = personaje.HumanoidRootPart.Position

					if estaDentroDeZona(posJugador) then
						local distancia = (posJugador - rootPart.Position).Magnitude
						
						if distancia < distanciaMinima then
							distanciaMinima = distancia
							jugadorCercano = personaje
						end
					end
				end
			end

			if jugadorCercano and jugadorCercano:FindFirstChild("HumanoidRootPart") then
				humanoid:MoveTo(jugadorCercano.HumanoidRootPart.Position)
			else
				if (rootPart.Position - posicionInicial).Magnitude > 5 then
					humanoid:MoveTo(posicionInicial)
				end
			end

			task.wait(0.5)
		end
	end)
end

-- Inicialización
for _, npc in pairs(CollectionService:GetTagged(TAG_NAME)) do
	configurarPolicia(npc)
end

CollectionService:GetInstanceAddedSignal(TAG_NAME):Connect(configurarPolicia)