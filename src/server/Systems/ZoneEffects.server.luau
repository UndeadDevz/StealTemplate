--[[
	═══════════════════════════════════════════════════════════════════════
	ZONE EFFECTS SYSTEM
	═══════════════════════════════════════════════════════════════════════

	Sistema de zonas usando CollectionService (Tags).

	TAGS DISPONIBLES:
	- KillZone: Mata instantáneamente al jugador
	- DamageZone: Hace daño configurable con cooldown
	- TrampolineZone: Trampolín que hace saltar al jugador
	- Conveyor: Cinta transportadora que mueve al jugador

	CÓMO USAR:
	1. Selecciona una Part en el Workspace
	2. En Properties, busca "Tags" o usa el Tag Editor
	3. Agrega el tag deseado (ej: "KillZone")

	═══════════════════════════════════════════════════════════════════════
]]

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- ═══════════════════════════════════════════════════════════════════════
-- TAG: KillZone (mata instantáneo)
-- ═══════════════════════════════════════════════════════════════════════
local function configurarKillZone(parte)
	if not parte:IsA("BasePart") then return end
	parte.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- TAG: DamageZone (hace daño)
-- ATRIBUTOS:
--   Damage (number): Daño que hace (default: 25)
--   Cooldown (number): Tiempo entre daños en segundos (default: 0.5)
-- ═══════════════════════════════════════════════════════════════════════
local function configurarDamageZone(parte)
	if not parte:IsA("BasePart") then return end
	local debounce = {}
	parte.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		local jugador = Players:GetPlayerFromCharacter(hit.Parent)
		if humanoid and jugador and not debounce[jugador] then
			debounce[jugador] = true
			local damage = parte:GetAttribute("Damage") or 25
			local cooldown = parte:GetAttribute("Cooldown") or 0.5
			humanoid:TakeDamage(damage)
			task.delay(cooldown, function()
				debounce[jugador] = nil
			end)
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- TAG: TrampolineZone (trampolín que hace saltar)
-- ATRIBUTOS:
--   BounceSpeed (number): Velocidad del rebote vertical (default: 80)
-- ═══════════════════════════════════════════════════════════════════════
local function configurarTrampolineZone(parte)
	if not parte:IsA("BasePart") then return end

	-- Establecer velocidad de la parte - la física de Roblox se encarga del resto
	local bounceSpeed = parte:GetAttribute("BounceSpeed") or 80
	parte.Velocity = Vector3.new(0, bounceSpeed, 0)
end

-- ═══════════════════════════════════════════════════════════════════════
-- TAG: Conveyor (cinta transportadora)
-- Usa AssemblyLinearVelocity de forma PASIVA (sin loop)
-- ATRIBUTOS:
--   Speed (number): Velocidad del conveyor (default: 20)
--   Direction (string): "Forward", "Backward", "Left", "Right" (default: "Forward")
-- ═══════════════════════════════════════════════════════════════════════
local function configurarConveyor(parte)
	if not parte:IsA("BasePart") then return end

	-- Anclar la parte para que no se mueva pero transmita velocidad
	parte.Anchored = true

	local function getDirection()
		local dir = parte:GetAttribute("Direction") or "Forward"
		if dir == "Forward" then
			return parte.CFrame.LookVector
		elseif dir == "Backward" then
			return -parte.CFrame.LookVector
		elseif dir == "Left" then
			return -parte.CFrame.RightVector
		elseif dir == "Right" then
			return parte.CFrame.RightVector
		else
			return parte.CFrame.LookVector
		end
	end

	local function actualizarVelocidad()
		local speed = parte:GetAttribute("Speed") or 20
		local direction = getDirection()
		parte.AssemblyLinearVelocity = direction * speed
	end

	-- Configurar una sola vez
	actualizarVelocidad()

	-- Solo actualizar si cambian los atributos
	parte.AttributeChanged:Connect(function(atributo)
		if atributo == "Speed" or atributo == "Direction" then
			actualizarVelocidad()
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- ACTIVAR TODAS LAS TAGS
-- ═══════════════════════════════════════════════════════════════════════

-- KillZone
for _, parte in CollectionService:GetTagged("KillZone") do
	configurarKillZone(parte)
end
CollectionService:GetInstanceAddedSignal("KillZone"):Connect(configurarKillZone)

-- DamageZone
for _, parte in CollectionService:GetTagged("DamageZone") do
	configurarDamageZone(parte)
end
CollectionService:GetInstanceAddedSignal("DamageZone"):Connect(configurarDamageZone)

-- TrampolineZone
for _, parte in CollectionService:GetTagged("TrampolineZone") do
	configurarTrampolineZone(parte)
end
CollectionService:GetInstanceAddedSignal("TrampolineZone"):Connect(configurarTrampolineZone)

-- Conveyor
for _, parte in CollectionService:GetTagged("Conveyor") do
	configurarConveyor(parte)
end
CollectionService:GetInstanceAddedSignal("Conveyor"):Connect(configurarConveyor)

print("[ZoneEffects] ✅ Sistema de zonas activado")
