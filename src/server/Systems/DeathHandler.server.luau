--[[
	═══════════════════════════════════════════════════════════════════════
	DEATH HANDLER SYSTEM
	═══════════════════════════════════════════════════════════════════════

	Maneja la muerte del jugador y el sistema de teleport a checkpoints.

	FLUJO:
	1. Jugador muere → Humanoid.Died
	2. Verifica si tiene checkpoint guardado
	3. Si SÍ tiene checkpoint: espera 3s y muestra popup
	4. Si NO tiene checkpoint: solo respawn normal
	5. Si compra teleport: valida y teleporta al checkpoint

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Configurar respawn rápido (3 segundos)
Players.RespawnTime = 3

-- Esperar a que CheckpointTracking esté disponible
print("[DeathHandler] ⏳ Esperando a que CheckpointSystem esté listo...")
local CheckpointTracking = nil
local maxWaitTime = 10
local waitedTime = 0

while not CheckpointTracking and waitedTime < maxWaitTime do
	CheckpointTracking = _G.CheckpointTracking
	if not CheckpointTracking then
		task.wait(0.5)
		waitedTime = waitedTime + 0.5
	end
end

if not CheckpointTracking then
	warn("[DeathHandler] ❌ CheckpointTracking no encontrado después de", maxWaitTime, "segundos")
	warn("[DeathHandler] ❌ Asegúrate de que CheckpointSystem.server.luau existe en src/server/Systems/")
	return
end

print("[DeathHandler] ✅ CheckpointTracking encontrado")

-- Esperar RemoteEvents
local function esperarRemoteEvents()
	local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
	if not remoteEventsFolder then
		warn("[DeathHandler] ⚠️ RemoteEvents folder no encontrado")
		return nil
	end

	local showDeathPopupEvent = remoteEventsFolder:WaitForChild("ShowDeathPopup", 10)
	local teleportToCheckpointEvent = remoteEventsFolder:WaitForChild("TeleportToCheckpoint", 10)

	if not showDeathPopupEvent or not teleportToCheckpointEvent then
		warn("[DeathHandler] ⚠️ RemoteEvents no encontrados")
		return nil
	end

	return showDeathPopupEvent, teleportToCheckpointEvent
end

local showDeathPopupEvent, teleportToCheckpointEvent = esperarRemoteEvents()
if not showDeathPopupEvent or not teleportToCheckpointEvent then
	return
end

-- ═══════════════════════════════════════════════════════════════════════
-- MANEJAR MUERTE DEL JUGADOR
-- ═══════════════════════════════════════════════════════════════════════
local function OnCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")

	humanoid.Died:Connect(function()
		print("💀 Jugador murió:", player.Name)

		-- Verificar si tiene checkpoint guardado
		local checkpointData = CheckpointTracking[player]

		if not checkpointData then
			print("ℹ️  No hay checkpoint guardado para:", player.Name, "- Solo respawn normal")
			return
		end

		-- Tiene checkpoint - mostrar popup después del respawn
		task.spawn(function()
			-- Esperar 3 segundos (tiempo de respawn automático)
			task.wait(3)

			-- Verificar que el jugador aún está conectado
			if not player or not player.Parent then
				return
			end

			print("📢 Mostrando popup de checkpoint para:", player.Name)

			-- Enviar info del checkpoint al cliente
			showDeathPopupEvent:FireClient(player, checkpointData)
		end)
	end)
end

-- Conectar a jugadores
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		OnCharacterAdded(player, character)
	end)

	-- Si ya tiene personaje
	if player.Character then
		OnCharacterAdded(player, player.Character)
	end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- HANDLER: TELEPORT A CHECKPOINT (después de compra)
-- ═══════════════════════════════════════════════════════════════════════
teleportToCheckpointEvent.OnServerEvent:Connect(function(player)
	print("🌀 Teleport request de:", player.Name)

	local checkpointData = CheckpointTracking[player]

	if not checkpointData then
		warn("⚠️  No hay checkpoint para", player.Name)
		return
	end

	-- Validar que el checkpoint aún existe
	local checkpointExists = false
	for _, parte in CollectionService:GetTagged("Checkpoint") do
		if parte:GetAttribute("CheckpointName") == checkpointData.CheckpointName then
			checkpointExists = true
			break
		end
	end

	if not checkpointExists then
		warn("⚠️  Checkpoint eliminado:", checkpointData.CheckpointName)
		-- TODO: Opcional - enviar mensaje de error al cliente
		return
	end

	-- Verificar que el jugador está vivo
	local character = player.Character
	if not character then
		warn("⚠️  Jugador no tiene personaje:", player.Name)
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		warn("⚠️  Jugador está muerto, no se puede teleportar:", player.Name)
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		warn("⚠️  No se encontró HumanoidRootPart para:", player.Name)
		return
	end

	print("💎 Teleportando a checkpoint:", player.Name, "->", checkpointData.CheckpointName)

	-- Teleportar con offset +5 en Y (evitar quedar atascado)
	rootPart.CFrame = CFrame.new(checkpointData.Position + Vector3.new(0, 5, 0))
end)

print("[DeathHandler] ✅ Sistema activado (RespawnTime = 3s)")
