--[[
	═══════════════════════════════════════════════════════════════════════
	CHECKPOINT SYSTEM
	═══════════════════════════════════════════════════════════════════════

	Sistema de checkpoints usando CollectionService (Tags).
	Los checkpoints se guardan en memoria durante la sesión actual del jugador.

	CÓMO USAR:
	1. Selecciona una Part en el Workspace
	2. En Properties, busca "Tags" o usa el Tag Editor
	3. Agrega el tag "Checkpoint"
	4. En Attributes, agrega "CheckpointName" (String) con un nombre descriptivo

	═══════════════════════════════════════════════════════════════════════
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

-- Tabla para guardar el último checkpoint de cada jugador
-- CheckpointTracking[player] = { CheckpointName = "...", Position = Vector3, LastTouchedTime = tick() }
local CheckpointTracking = {}

-- ═══════════════════════════════════════════════════════════════════════
-- TAG: Checkpoint
-- ATRIBUTOS:
--   CheckpointName (string): Nombre identificador del checkpoint
-- ═══════════════════════════════════════════════════════════════════════
local function configurarCheckpoint(parte)
	if not parte:IsA("BasePart") then return end

	-- Validar que tenga el atributo CheckpointName
	local checkpointName = parte:GetAttribute("CheckpointName")
	if not checkpointName or checkpointName == "" then
		warn("[Checkpoint] Part sin atributo CheckpointName o vacío:", parte:GetFullName())
		return
	end

	local debounce = {}

	parte.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and not debounce[player] then
			debounce[player] = true

			-- Guardar checkpoint en memoria
			CheckpointTracking[player] = {
				CheckpointName = checkpointName,
				Position = parte.Position,
				LastTouchedTime = tick()
			}

			print("✅ Checkpoint guardado:", player.Name, "->", checkpointName)

			-- Cooldown de 1 segundo
			task.delay(1, function()
				debounce[player] = nil
			end)
		end
	end)
end

-- Activar checkpoints existentes
for _, parte in CollectionService:GetTagged("Checkpoint") do
	configurarCheckpoint(parte)
end

-- Detectar nuevos checkpoints
CollectionService:GetInstanceAddedSignal("Checkpoint"):Connect(configurarCheckpoint)

-- Limpieza al salir del juego
Players.PlayerRemoving:Connect(function(player)
	CheckpointTracking[player] = nil
	print("🧹 Checkpoint tracking limpiado para:", player.Name)
end)

-- Exportar para que DeathHandler pueda acceder
_G.CheckpointTracking = CheckpointTracking

print("[CheckpointSystem] ✅ Sistema activado")
