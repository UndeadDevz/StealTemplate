local Players = game:GetService("Players")

-- Referencia al DataManager
local DataManager = require(script.Parent.Parent.Data.DataManager)

local CARPETA_ZONAS = "ZonasWins" -- Nombre de la carpeta en Workspace

-- Función para enviar al jugador al Spawn
local function TeleportToSpawn(player)
	local character = player.Character
	if character then
		-- Busca el SpawnLocation por defecto de Roblox
		local spawn = workspace:FindFirstChild("SpawnLocation")

		local targetCFrame
		if spawn and spawn:IsA("BasePart") then
			-- Si existe spawn, ir encima de él
			targetCFrame = spawn.CFrame + Vector3.new(0, 5, 0)
		else
			-- Si no hay spawn, ir al centro del mapa (o cambia estas coordenadas)
			targetCFrame = CFrame.new(0, 50, 0)
			warn("[WinZones] No se encontró SpawnLocation, enviando a 0,50,0")
		end

		-- Teletransportar (PivotTo es la forma moderna y más segura de mover personajes)
		character:PivotTo(targetCFrame)
	end
end

-- Configura cada parte de zona
local function SetupZone(zona)
	if not zona:IsA("BasePart") then
		return
	end

	-- Tabla para evitar que se active muchas veces seguidas (Debounce)
	local cooldowns = {}

	zona.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)

		if player then
			-- Si el jugador está en cooldown, no hacer nada
			if cooldowns[player] then
				return
			end

			-- Activar cooldown temporalmente
			cooldowns[player] = true

			-- 1. Dar Wins
			-- "wins" en minúscula es la clave en tu Template.luau
			-- Busca el atributo "Wins" en la parte, si no tiene, da 1 por defecto
			local winsAmount = zona:GetAttribute("Wins") or 1
			DataManager.AddStat(player, "Wins", winsAmount)
			print("🏆 " .. player.Name .. " recibió " .. winsAmount .. " Win(s)!")

			-- 2. Teletransportar al Spawn
			TeleportToSpawn(player)

			-- 3. Liberar cooldown después de un momento (por seguridad)
			task.wait(2)
			cooldowns[player] = nil
		end
	end)
end

-- Inicialización
local zonasFolder = workspace:FindFirstChild(CARPETA_ZONAS)

if zonasFolder then
	-- Configurar las zonas que ya existen
	for _, child in pairs(zonasFolder:GetChildren()) do
		SetupZone(child)
	end

	-- Configurar nuevas zonas si se añaden después
	zonasFolder.ChildAdded:Connect(SetupZone)
else
	warn("[WinZones] ⚠️ No se encontró la carpeta '" .. CARPETA_ZONAS .. "' en Workspace.")
end
