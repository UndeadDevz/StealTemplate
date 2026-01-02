--[[
	═══════════════════════════════════════════════════════════════════════
	SCRIPT DE CONFIGURACIÓN RÁPIDA - SOLO EJECUTAR UNA VEZ EN COMMAND BAR
	═══════════════════════════════════════════════════════════════════════
	
	Este script crea automáticamente la estructura de carpetas y el objeto
	de partículas base en ReplicatedStorage.
	
	CÓMO USAR:
	1. Copia TODO este script
	2. En Roblox Studio, abre el Command Bar (View > Command Bar)
	3. Pega el código y presiona Enter
	4. Ve a ReplicatedStorage > Effects > LevelUpEffect
	5. Personaliza las partículas a tu gusto
	
	═══════════════════════════════════════════════════════════════════════
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear carpeta de efectos
local effectsFolder = ReplicatedStorage:FindFirstChild("Effects")
if not effectsFolder then
	effectsFolder = Instance.new("Folder")
	effectsFolder.Name = "Effects"
	effectsFolder.Parent = ReplicatedStorage
	print("✅ Carpeta 'Effects' creada en ReplicatedStorage")
end

-- Crear objeto base del efecto
local levelUpEffect = effectsFolder:FindFirstChild("LevelUpEffect")
if not levelUpEffect then
	levelUpEffect = Instance.new("Part")
	levelUpEffect.Name = "LevelUpEffect"
	levelUpEffect.Size = Vector3.new(1, 1, 1)
	levelUpEffect.Transparency = 1
	levelUpEffect.CanCollide = false
	levelUpEffect.Anchored = false
	levelUpEffect.Parent = effectsFolder
	
	-- Crear Attachment
	local attachment = Instance.new("Attachment")
	attachment.Name = "ParticleAttachment"
	attachment.Parent = levelUpEffect
	
	-- Crear 4 partículas dentro del Attachment
	for i = 1, 4 do
		local particle = Instance.new("ParticleEmitter")
		particle.Name = "Particle" .. i
		particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particle.Lifetime = NumberRange.new(1, 2)
		particle.Rate = 0 -- Se dispara manualmente con :Emit()
		particle.Speed = NumberRange.new(5, 10)
		particle.SpreadAngle = Vector2.new(360, 360)
		particle.Rotation = NumberRange.new(0, 360)
		particle.RotSpeed = NumberRange.new(-100, 100)
		particle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0)) -- Amarillo
		particle.Size = NumberSequence.new(0.5)
		particle.LightEmission = 1
		particle.Parent = attachment
	end
	
	-- Crear 1 partícula fuera del Attachment
	local particleExtra = Instance.new("ParticleEmitter")
	particleExtra.Name = "ParticleExtra"
	particleExtra.Texture = "rbxasset://textures/particles/fire_main.dds"
	particleExtra.Lifetime = NumberRange.new(0.5, 1)
	particleExtra.Rate = 0
	particleExtra.Speed = NumberRange.new(3, 6)
	particleExtra.SpreadAngle = Vector2.new(360, 360)
	particleExtra.Color = ColorSequence.new(Color3.fromRGB(255, 200, 50)) -- Naranja
	particleExtra.Size = NumberSequence.new(1)
	particleExtra.LightEmission = 0.8
	particleExtra.Parent = levelUpEffect
	
	print("✅ Efecto 'LevelUpEffect' creado con 5 partículas")
	print("📍 Ubicación: ReplicatedStorage > Effects > LevelUpEffect")
	print("🎨 Personaliza las partículas a tu gusto en las propiedades")
end

print("🎉 ¡Configuración completada!")
