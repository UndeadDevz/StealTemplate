--[[
	NO PLAYER COLLISIONS - Desactiva colisiones entre jugadores
	Usa CollisionGroup para que los jugadores no colisionen entre sí
]]

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local COLLISION_GROUP = "Players"

-- ========== SETUP COLLISION GROUP PRIMERO ==========
-- Registrar grupo (ignora error si ya existe)
pcall(function()
	PhysicsService:RegisterCollisionGroup(COLLISION_GROUP)
end)

-- Hacer que Players no colisione consigo mismo
PhysicsService:CollisionGroupSetCollidable(COLLISION_GROUP, COLLISION_GROUP, false)
print("[NoPlayerCollisions] ✓ CollisionGroup configurado")

-- ========== APLICAR A PERSONAJES ==========
local function applyCollisionGroup(character)
	if not character or not character.Parent then return end

	-- Aplicar a todas las partes existentes
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CollisionGroup = COLLISION_GROUP
		end
	end
end

local function setupCharacter(player, character)
	-- Esperar a que el personaje esté listo
	local hrp = character:WaitForChild("HumanoidRootPart", 10)
	if not hrp then
		warn("[NoPlayerCollisions] ⚠️ HRP no encontrado para:", player.Name)
		return
	end

	-- Aplicar inmediatamente
	applyCollisionGroup(character)

	-- Aplicar de nuevo después de un delay (para partes tardías)
	task.delay(0.5, function()
		if character and character.Parent then
			applyCollisionGroup(character)
		end
	end)

	-- Aplicar una vez más después de 1 segundo (por si acaso)
	task.delay(1, function()
		if character and character.Parent then
			applyCollisionGroup(character)
		end
	end)

	-- Escuchar nuevas partes (accesorios que se agregan después)
	character.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") then
			desc.CollisionGroup = COLLISION_GROUP
		end
	end)

	print("[NoPlayerCollisions] ✓ Aplicado a:", player.Name)
end

local function onPlayerAdded(player)
	-- Futuros respawns - conectar PRIMERO
	player.CharacterAdded:Connect(function(char)
		task.spawn(setupCharacter, player, char)
	end)

	-- Personaje actual (si existe)
	if player.Character then
		task.spawn(setupCharacter, player, player.Character)
	end
end

-- ========== INICIALIZAR ==========
-- Conectar evento PlayerAdded PRIMERO (antes de iterar)
Players.PlayerAdded:Connect(onPlayerAdded)

-- Jugadores que ya existen
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

-- IMPORTANTE: Re-aplicar a TODOS los personajes después de 2 segundos
-- Esto asegura que jugadores que se unieron muy rápido también tengan el CollisionGroup
task.delay(2, function()
	print("[NoPlayerCollisions] 🔄 Re-aplicando a todos los jugadores...")
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			applyCollisionGroup(player.Character)
			print("[NoPlayerCollisions] ✓ Re-aplicado a:", player.Name)
		end
	end
end)

print("[NoPlayerCollisions] ✓ Sistema listo")
