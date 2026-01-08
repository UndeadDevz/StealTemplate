local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)
local CollectionService = game:GetService("CollectionService")

-- Esperar al RemoteEvent
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local changeCarModel = remoteEvents:WaitForChild("ChangeCarModel")

local function SetupEquipZone(zona)
	if not zona:IsA("BasePart") then return end
	
	-- Debounce para no spamear el mensaje al tocar
	local cooldowns = {}

	zona.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end
		
		if cooldowns[player] then return end
		cooldowns[player] = true
		
		-- 1. Obtener datos necesarios
		local equipType = zona:GetAttribute("EquipType")
		if not equipType then 
			warn("La zona " .. zona.Name .. " no tiene atributo EquipType")
			task.wait(1)
			cooldowns[player] = nil
			return 
		end
		
		-- Tabla de victorias requeridas por equipType (1 a 8)
		local winsPorEquipType = {0, 3, 15, 75, 400, 2000, 10000, 40000}
		local winsRequeridas = winsPorEquipType[equipType] or 0
		local currentWins = DataManager.GetStat(player, "Wins") or 0
		local currentEquip = DataManager.GetStat(player, "EquipType") or 1
		
		-- 2. Verificar lógica
		if currentEquip == equipType then
			-- Ya lo tiene equipado
			print("ℹ️ " .. player.Name .. " ya tiene equipado EquipType " .. equipType)
		elseif currentWins >= winsRequeridas then
			-- TIENE SUFICIENTES WINS: Equipar
			DataManager.UpdateStat(player, "EquipType", equipType)
			print("⚔️ " .. player.Name .. " equipó Multiplicador x" .. equipType .. "!")

			-- Notificar a TODOS los clientes para cambiar modelo/texturas
			-- Envía el EquipType, los clientes deciden si recargar o solo cambiar texturas
			changeCarModel:FireAllClients(player, equipType)

			-- Opcional: Feedback visual (puedes añadir sonido o partículas aquí)
		else
			-- NO TIENE SUFICIENTES WINS
			print("🔒 Necesitas " .. winsRequeridas .. " Wins para equipar esto. Tienes: " .. currentWins)
		end
		
		task.wait(1) -- Esperar 1 segundo antes de poder volver a intentar
		cooldowns[player] = nil
	end)
end


-- Define el nombre de la etiqueta que usarás en el Tag Editor
local TAG_ZONA_EQUIPO = "EquipZone"

-- Función para inicializar cada zona
local function onInstanceAdded(instance)
	if instance:IsA("BasePart") then
		SetupEquipZone(instance)
	end
end

-- 1. Buscar las que ya existen en el juego al iniciar
for _, instance in pairs(CollectionService:GetTagged(TAG_ZONA_EQUIPO)) do
	onInstanceAdded(instance)
end

-- 2. Escuchar por si se crean nuevas zonas o se les agrega el tag en tiempo de ejecución
CollectionService:GetInstanceAddedSignal(TAG_ZONA_EQUIPO):Connect(onInstanceAdded)

print("✅ Sistema de etiquetas activado para: " .. TAG_ZONA_EQUIPO)