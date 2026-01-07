--[[
	DEATH HANDLER - Sistema simple de muerte y checkpoint
	Muestra el botón cuando el jugador muere si tiene checkpoint guardado
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configurar respawn rápido (3 segundos)
Players.RespawnTime = 3

-- Esperar CheckpointTracking
print("[DeathHandler] Esperando CheckpointTracking...")
local CheckpointTracking = nil
for i = 1, 20 do
	CheckpointTracking = _G.CheckpointTracking
	if CheckpointTracking then break end
	task.wait(0.5)
end

if not CheckpointTracking then
	warn("[DeathHandler] ❌ No se encontró CheckpointTracking")
	return
end

print("[DeathHandler] ✅ CheckpointTracking encontrado")

-- Esperar RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEvents then
	warn("[DeathHandler] ❌ No se encontró RemoteEvents")
	return
end

local showEvent = remoteEvents:WaitForChild("ShowDeathPopup", 10)
local teleportEvent = remoteEvents:WaitForChild("TeleportToCheckpoint", 10)

if not showEvent or not teleportEvent then
	warn("[DeathHandler] ❌ No se encontraron los RemoteEvents")
	return
end

print("[DeathHandler] ✅ RemoteEvents encontrados")

-- Función para conectar a un jugador
local function setupPlayer(player)
	print("[DeathHandler] 🔧 Configurando jugador:", player.Name)

	-- Función para conectar a un personaje
	local function setupCharacter(character)
		print("[DeathHandler] 👤 Configurando personaje para:", player.Name)
		local humanoid = character:WaitForChild("Humanoid")

		print("[DeathHandler] ❤️ Conectando evento Died para:", player.Name)
		humanoid.Died:Connect(function()
			print("💀", player.Name, "murió")

			-- Verificar si tiene checkpoint
			local checkpoint = CheckpointTracking[player]
			if not checkpoint then
				print("ℹ️", player.Name, "no tiene checkpoint guardado")
				return
			end

			print("✅", player.Name, "tiene checkpoint:", checkpoint.CheckpointName)

			-- Esperar a que respawnee (3 segundos)
			task.wait(3.1)

			-- Verificar que sigue conectado
			if not player or not player.Parent then
				print("⚠️", player.Name, "se desconectó")
				return
			end

			-- Mostrar botón
			print("📢 ENVIANDO EVENTO para mostrar botón a", player.Name)
			showEvent:FireClient(player, checkpoint)
		end)
	end

	-- Conectar a CharacterAdded
	player.CharacterAdded:Connect(setupCharacter)

	-- Si ya tiene personaje, configurarlo
	if player.Character then
		setupCharacter(player.Character)
	end
end

-- Conectar jugadores nuevos
Players.PlayerAdded:Connect(setupPlayer)

-- Conectar jugadores que ya estén en el juego
for _, player in pairs(Players:GetPlayers()) do
	setupPlayer(player)
end

-- Handler de teleport
teleportEvent.OnServerEvent:Connect(function(player)
	print("🌀 Teleport solicitado por", player.Name)

	local checkpoint = CheckpointTracking[player]
	if not checkpoint then
		warn("⚠️ No hay checkpoint para", player.Name)
		return
	end

	local character = player.Character
	if not character then
		warn("⚠️", player.Name, "no tiene personaje")
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		warn("⚠️", player.Name, "no tiene HumanoidRootPart")
		return
	end

	print("💎 Teleportando", player.Name, "a", checkpoint.CheckpointName)
	rootPart.CFrame = CFrame.new(checkpoint.Position + Vector3.new(0, 5, 0))
end)

print("[DeathHandler] ✅ Sistema activado")
