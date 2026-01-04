--[[
	═══════════════════════════════════════════════════════════════════════
	HANDLER DE VELOCIDAD PERSONALIZADA
	═══════════════════════════════════════════════════════════════════════
	
	Permite a los jugadores elegir su velocidad dentro del rango permitido
	según su nivel. La validación se hace en el servidor para evitar exploits.
	
	═══════════════════════════════════════════════════════════════════════
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- Configuración
local BASE_SPEED = 16

-- Calcula la velocidad máxima permitida según el nivel
local function GetMaxSpeed(level: number): number
	return BASE_SPEED + (level * 2)
end

-- Esperar a que existan los RemoteEvents
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local setCustomSpeedEvent = remoteEventsFolder:WaitForChild("SetCustomSpeed")

setCustomSpeedEvent.OnServerEvent:Connect(function(player: Player, velocidadDeseada: number)
	-- Validar que el argumento sea un número
	if typeof(velocidadDeseada) ~= "number" then
		warn("❌ SetCustomSpeed: Velocidad inválida de", player.Name)
		return
	end
	
	-- Validar que no sea NaN o infinito
	if velocidadDeseada ~= velocidadDeseada or velocidadDeseada == math.huge then
		warn("❌ SetCustomSpeed: Velocidad NaN/Infinita de", player.Name)
		return
	end
	
	-- Obtener el nivel del jugador desde el servidor (fuente confiable)
	local nivel = DataManager.GetStat(player, "Level") or 1
	local maxSpeedPermitida = GetMaxSpeed(nivel)
	
	-- Aplicar clamp para mantener la velocidad en rango válido
	local velocidadFinal = math.clamp(velocidadDeseada, BASE_SPEED, maxSpeedPermitida)
	
	-- Guardar la velocidad personalizada en el perfil del jugador
	DataManager.UpdateStat(player, "CustomSpeed", velocidadFinal)
	
	-- Aplicar la velocidad al humanoid
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = velocidadFinal
			print("✅ Velocidad de", player.Name, "establecida a:", velocidadFinal, "(Max:", maxSpeedPermitida, ")")
		end
	end
	
	-- Enviar respuesta al cliente con la velocidad final aplicada
	setCustomSpeedEvent:FireClient(player, velocidadFinal)
end)

print("✅ CustomSpeedHandler inicializado")
