--[[
	═══════════════════════════════════════════════════════════════════════
	WINS SYSTEM - Sistema de zonas de victoria
	═══════════════════════════════════════════════════════════════════════

	CÓMO CONFIGURAR UNA ZONA DE WIN:
	1. Crea una Part en el Workspace
	2. Agrega el Tag "WinZone" usando el Tag Editor
	3. Configura el atributo:
	   - Wins (number): Cantidad de wins que da (por defecto: 1)

	MULTIPLICADOR x2 WINS (GamePass):
	- Si el jugador tiene el GamePass x2 Wins, todas las wins se multiplican por 2
	- Es una compra permanente (GamePass)
	- Se aplica automáticamente a todas las zonas

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Referencia al DataManager
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- ========== CONFIGURACIÓN ==========
local TAG_WIN_ZONE = "WinZone"
local X2_WINS_GAMEPASS_ID = 1661925212 -- GamePass "x2 Wins"
-- ===================================

-- Cache para GamePass (evitar múltiples llamadas a la API)
local gamePassCache = {}

-- Tabla para trackear a quién ya le mostramos la notificación
local notifiedPlayers = {}

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
			-- Si no hay spawn, ir al centro del mapa
			targetCFrame = CFrame.new(0, 50, 0)
			warn("[WinsSystem] No se encontró SpawnLocation, enviando a 0,50,0")
		end

		-- Teletransportar
		character:PivotTo(targetCFrame)
	end
end

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
		warn("[WinsSystem] Error al verificar GamePass:", ownsPass)
		return false
	end
end

-- Configura cada zona de win
local function SetupZone(zona)
	if not zona:IsA("BasePart") then
		warn("[WinsSystem] ⚠️ El objeto con tag 'WinZone' no es una BasePart:", zona:GetFullName())
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

			-- Obtener cantidad de wins base
			local baseWins = zona:GetAttribute("Wins") or 1

			-- Verificar si tiene el GamePass x2 Wins
			local hasX2Pass = PlayerHasX2Wins(player)
			local finalWins = baseWins

			if hasX2Pass then
				finalWins = baseWins * 2
				print("🌟 " .. player.Name .. " tiene x2 Wins GamePass! " .. baseWins .. " → " .. finalWins)
			else
				-- Si no tiene el GamePass y aún no le hemos notificado
				if not notifiedPlayers[player.UserId] then
					notifiedPlayers[player.UserId] = true

					-- Enviar notificación al cliente
					local ReplicatedStorage = game:GetService("ReplicatedStorage")
					local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
					if remoteEvents then
						local notifyEvent = remoteEvents:FindFirstChild("NotifyX2WinsAvailable")
						if notifyEvent then
							notifyEvent:FireClient(player, baseWins)
						end
					end
				end
			end

			-- Dar Wins
			DataManager.AddStat(player, "Wins", finalWins)
			print("🏆 " .. player.Name .. " recibió " .. finalWins .. " Win(s)!")

			-- Teletransportar al Spawn
			TeleportToSpawn(player)

			-- Liberar cooldown
			task.wait(2)
			cooldowns[player] = nil
		end
	end)

	print("[WinsSystem] ✓ Zona configurada:", zona.Name, "| Wins base:", zona:GetAttribute("Wins") or 1)
end

-- ========== INICIALIZACIÓN ==========

-- Configurar zonas que ya existen
for _, zona in pairs(CollectionService:GetTagged(TAG_WIN_ZONE)) do
	SetupZone(zona)
end

-- Configurar nuevas zonas cuando se agreguen el tag
CollectionService:GetInstanceAddedSignal(TAG_WIN_ZONE):Connect(SetupZone)

-- Limpiar cuando se remueva el tag
CollectionService:GetInstanceRemovedSignal(TAG_WIN_ZONE):Connect(function(zona)
	print("[WinsSystem] ⚠️ Tag removido de:", zona.Name)
end)

-- Limpiar cache cuando un jugador se va
Players.PlayerRemoving:Connect(function(player)
	gamePassCache[player.UserId] = nil
	notifiedPlayers[player.UserId] = nil
end)

print("[WinsSystem] ✓ Sistema inicializado - Tag:", TAG_WIN_ZONE)
