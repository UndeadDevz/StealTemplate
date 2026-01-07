--[[
	DEATH HANDLER - Sistema simple de muerte y checkpoint

	GAMEPASS x2 Wins:
	- Los jugadores con el GamePass tienen respawns ILIMITADOS y GRATIS
	- No necesitan pagar el producto CheckpointTeleport

	Sin GamePass:
	- Muestra el botón cuando el jugador muere si tiene checkpoint guardado
	- Requiere comprar el producto CheckpointTeleport (10 Robux)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- ========== CONFIGURACIÓN ==========
local X2_WINS_GAMEPASS_ID = 1694367675565474295 -- GamePass "x2 Wins"
-- ===================================

-- Configurar respawn rápido (3 segundos)
Players.RespawnTime = 3

-- Cache para GamePass
local gamePassCache = {}

-- Función para verificar si el jugador tiene el GamePass x2 Wins
local function PlayerHasX2Wins(player)
	if X2_WINS_GAMEPASS_ID == 0 then
		return false
	end

	-- Verificar en cache primero
	if gamePassCache[player.UserId] ~= nil then
		return gamePassCache[player.UserId]
	end

	-- Verificar con la API de Roblox
	local success, ownsPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, X2_WINS_GAMEPASS_ID)
	end)

	if success then
		gamePassCache[player.UserId] = ownsPass
		return ownsPass
	else
		warn("[DeathHandler] Error al verificar GamePass:", ownsPass)
		return false
	end
end

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
local notifyFreeRespawnEvent = remoteEvents:WaitForChild("NotifyFreeRespawn", 10)

if not showEvent or not teleportEvent or not notifyFreeRespawnEvent then
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

			-- Verificar si tiene el GamePass x2 Wins
			local hasX2Pass = PlayerHasX2Wins(player)

			if hasX2Pass then
				-- RESPAWN GRATIS - Teleportar directamente al checkpoint
				print("🌟", player.Name, "tiene x2 Wins GamePass - RESPAWN GRATIS!")

				local character = player.Character
				if character then
					local rootPart = character:FindFirstChild("HumanoidRootPart")
					if rootPart then
						print("💎 Teleportando", player.Name, "a", checkpoint.CheckpointName, "(GRATIS)")
						rootPart.CFrame = CFrame.new(checkpoint.Position + Vector3.new(0, 5, 0))

						-- Notificar al cliente sobre el respawn gratis
						notifyFreeRespawnEvent:FireClient(player, checkpoint.CheckpointName)
					end
				end
			else
				-- Sin GamePass, mostrar botón de compra
				print("📢 ENVIANDO EVENTO para mostrar botón a", player.Name)
				showEvent:FireClient(player, checkpoint)
			end
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

-- Handler de teleport (para compras via Developer Product)
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

-- Limpiar cache cuando un jugador se va
Players.PlayerRemoving:Connect(function(player)
	gamePassCache[player.UserId] = nil
end)

print("[DeathHandler] ✅ Sistema activado")
