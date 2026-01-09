--[[
	═══════════════════════════════════════════════════════════════════════
	NO PLAYER COLLISIONS - Desactiva colisiones entre jugadores
	═══════════════════════════════════════════════════════════════════════

	Este sistema usa la nueva API de CollisionGroup (string) para prevenir
	que los jugadores colisionen entre sí.

	CÓMO FUNCIONA:
	- Registra un grupo de colisión llamado "Players"
	- Configura que este grupo no colisione consigo mismo
	- Asigna este grupo a todas las partes del personaje usando BasePart.CollisionGroup

	NOTA: Usa las APIs modernas de Roblox (RegisterCollisionGroup + BasePart.CollisionGroup)
	en lugar de las APIs deprecadas (CreateCollisionGroup + SetPartCollisionGroup)

	═══════════════════════════════════════════════════════════════════════
]]

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- ========== CONFIGURACIÓN ==========
local COLLISION_GROUP_NAME = "Players"
-- ===================================

-- Registrar grupo de colisión si no existe
local function registerCollisionGroup()
	local success, err = pcall(function()
		PhysicsService:RegisterCollisionGroup(COLLISION_GROUP_NAME)
	end)

	if not success then
		-- Si ya existe, no hay problema
		if not string.find(err, "already") then
			warn("[NoPlayerCollisions] Error al registrar grupo de colisión:", err)
			return false
		end
	end

	-- Configurar que el grupo "Players" no colisione consigo mismo
	PhysicsService:CollisionGroupSetCollidable(COLLISION_GROUP_NAME, COLLISION_GROUP_NAME, false)

	print("[NoPlayerCollisions] ✓ Grupo de colisión configurado:", COLLISION_GROUP_NAME)
	return true
end

-- Aplicar grupo de colisión a todas las partes del personaje usando la nueva API
local function setCharacterCollisionGroup(character)
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			-- Usar la nueva propiedad CollisionGroup (string) en lugar de SetPartCollisionGroup
			pcall(function()
				part.CollisionGroup = COLLISION_GROUP_NAME
			end)
		end
	end
end

-- Manejar cuando un jugador spawna
local function onCharacterAdded(character)
	-- Esperar a que el personaje cargue completamente
	character:WaitForChild("HumanoidRootPart", 5)

	-- Aplicar grupo de colisión
	setCharacterCollisionGroup(character)

	-- Escuchar nuevas partes que se agreguen al personaje (como accesorios)
	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			pcall(function()
				descendant.CollisionGroup = COLLISION_GROUP_NAME
			end)
		end
	end)

	print("[NoPlayerCollisions] ✓ Colisiones desactivadas para:", character.Name)
end

-- Manejar cuando un jugador se une
local function onPlayerAdded(player)
	-- Manejar personaje actual si existe
	if player.Character then
		onCharacterAdded(player.Character)
	end

	-- Manejar futuros respawns
	player.CharacterAdded:Connect(onCharacterAdded)
end

-- ========== INICIALIZACIÓN ==========

-- Registrar grupo de colisión
if not registerCollisionGroup() then
	warn("[NoPlayerCollisions] ⚠️ No se pudo inicializar el sistema de colisiones")
	return
end

-- Configurar jugadores actuales
for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

-- Configurar nuevos jugadores
Players.PlayerAdded:Connect(onPlayerAdded)

print("[NoPlayerCollisions] ✓ Sistema inicializado - Los jugadores no colisionarán entre sí")
