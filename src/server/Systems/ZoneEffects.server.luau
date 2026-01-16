--[[
    ═══════════════════════════════════════════════════════════════════════
    ZONE EFFECTS SYSTEM (OPTIMIZED v2)
    ═══════════════════════════════════════════════════════════════════════
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

-- Configuración global
local POLLING_RATE = 0.1 -- Se revisan las zonas cada 0.1 segundos (10 veces por seg)
local damageDebounces = {} -- Para el DamageZone

-- ═══════════════════════════════════════════════════════════════════════
-- LÓGICA DE VELOCIDAD (Trampolines y Conveyors)
-- Estas NO usan bucles, son físicas puras de Roblox (Rate: 0)
-- ═══════════════════════════════════════════════════════════════════════

local function configurarFisica(parte)
	if not parte:IsA("BasePart") then return end
	parte.Anchored = true
	
	local function actualizar()
		local tag = ""
		if CollectionService:HasTag(parte, "Conveyor") then
			local speed = parte:GetAttribute("Speed") or 20
			local dir = parte:GetAttribute("Direction") or "Forward"
			local look = parte.CFrame.LookVector
			local right = parte.CFrame.RightVector
			
			local vel = look -- Default Forward
			if dir == "Backward" then vel = -look
			elseif dir == "Left" then vel = -right
			elseif dir == "Right" then vel = right end
			
			parte.AssemblyLinearVelocity = vel * speed
		
		elseif CollectionService:HasTag(parte, "TrampolineZone") then
			local bounce = parte:GetAttribute("BounceSpeed") or 80
			parte.AssemblyLinearVelocity = Vector3.new(0, bounce, 0)
		end
	end

	actualizar()
	parte.AttributeChanged:Connect(actualizar)
end

-- ═══════════════════════════════════════════════════════════════════════
-- BUCLE CENTRAL DE DETECCIÓN (Kill y Damage)
-- Esto sustituye al .Touched y baja drásticamente el Rate
-- ═══════════════════════════════════════════════════════════════════════

task.spawn(function()
	while true do
		-- 1. ZONAS DE MUERTE (KillZone)
		for _, zona in CollectionService:GetTagged("KillZone") do
			local partesTocando = workspace:GetPartsInPart(zona)
			for _, p in partesTocando do
				local hum = p.Parent:FindFirstChild("Humanoid")
				if hum and hum.Health > 0 then
					hum.Health = 0
				end
			end
		end

		-- 2. ZONAS DE DAÑO (DamageZone)
		for _, zona in CollectionService:GetTagged("DamageZone") do
			local partesTocando = workspace:GetPartsInPart(zona)
			local damage = zona:GetAttribute("Damage") or 25
			local cooldown = zona:GetAttribute("Cooldown") or 0.5
			
			for _, p in partesTocando do
				local char = p.Parent
				local player = Players:GetPlayerFromCharacter(char)
				local hum = char:FindFirstChild("Humanoid")
				
				if hum and hum.Health > 0 and player then
					local lastDamage = damageDebounces[player] or 0
					if tick() - lastDamage >= cooldown then
						damageDebounces[player] = tick()
						hum:TakeDamage(damage)
					end
				end
			end
		end

		task.wait(POLLING_RATE)
	end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- INICIALIZACIÓN
-- ═══════════════════════════════════════════════════════════════════════

-- Configurar los que ya existen y los que se agreguen después
local function setup(parte)
	if CollectionService:HasTag(parte, "Conveyor") or CollectionService:HasTag(parte, "TrampolineZone") then
		configurarFisica(parte)
	end
end

-- Escuchar etiquetas para Trampolines/Conveyors
for _, tag in {"Conveyor", "TrampolineZone"} do
	for _, inst in CollectionService:GetTagged(tag) do setup(inst) end
	CollectionService:GetInstanceAddedSignal(tag):Connect(setup)
end

-- Limpieza de debounces cuando el jugador se va
Players.PlayerRemoving:Connect(function(player)
	damageDebounces[player] = nil
end)

print("[ZoneEffects] ✅ Sistema optimizado activado (Polling Mode)")