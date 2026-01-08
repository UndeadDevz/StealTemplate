local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)

local CARPETA_EQUIPO = "ZonasEquipo"

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
		
		local winsRequeridas = equipType * 100
		local currentWins = DataManager.GetStat(player, "Wins") or 0
		local currentEquip = DataManager.GetStat(player, "EquipType") or 1
		
		-- 2. Verificar lógica
		if currentEquip == equipType then
			-- Ya lo tiene equipado
			-- (Opcional: print("Ya tienes equipado este multiplicador"))
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

-- Inicialización
local folder = workspace:FindFirstChild(CARPETA_EQUIPO)
if folder then
	for _, child in pairs(folder:GetChildren()) do
		SetupEquipZone(child)
	end
	folder.ChildAdded:Connect(SetupEquipZone)
else
	warn("⚠️ Crea la carpeta '" .. CARPETA_EQUIPO .. "' en Workspace con tus partes.")
end