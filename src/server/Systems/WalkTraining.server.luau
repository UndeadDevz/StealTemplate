local Players = game:GetService("Players")

-- Referencia al DataManager
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- CONFIGURACIÓN
local EXP_POR_SEGUNDO = 10 -- Cantidad de EXP a ganar cada segundo
local INTERVALO = 1 -- Tiempo en segundos (1 segundo)
local UMBRAL_MOVIMIENTO = 0.5 -- Mínima distancia para considerar que "caminó" (evita ganar EXP por temblor de animación)

-- Tabla para guardar la última posición conocida
local lastPositions = {}

local function CleanupPlayer(player)
	lastPositions[player] = nil
end

Players.PlayerRemoving:Connect(CleanupPlayer)

while true do
	task.wait(INTERVALO)

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character

		-- Verificar que el personaje existe y está vivo
		if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
			local humanoid = character.Humanoid
			local rootPart = character.HumanoidRootPart

			if humanoid.Health > 0 then
				local currentPos = rootPart.Position
				local lastPos = lastPositions[player]

				if lastPos then
					-- Calcular distancia recorrida en este último segundo
					-- Usamos Vector3.new para ignorar saltos (altura Y), solo movimiento horizontal
					local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(lastPos.X, 0, lastPos.Z)).Magnitude

					-- Si se movió más que el umbral y menos que un teleport exagerado
					if dist > UMBRAL_MOVIMIENTO and dist < 100 then
						-- Dar EXP
						DataManager.AddStat(player, "EXP", EXP_POR_SEGUNDO)
						DataManager.CheckLevelUp(player)

						-- Opcional: Feedback en consola
						-- print(player.Name .. " caminó 1 seg (+ " .. EXP_POR_SEGUNDO .. " EXP)")
					end
				end

				-- Actualizar posición para la siguiente comprobación
				lastPositions[player] = currentPos
			else
				-- Si está muerto, reseteamos su posición para no contar el respawn como caminata
				lastPositions[player] = nil
			end
		end
	end
end
