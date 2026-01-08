--[[
	═══════════════════════════════════════════════════════════════════════
	INITIAL EQUIPTYPE NOTIFIER
	═══════════════════════════════════════════════════════════════════════

	Notifica al jugador su EquipType actual cuando entra al juego.
	Esto inicializa el caché del cliente sin necesidad de tocar una zona.

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- Esperar al RemoteEvent
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local changeCarModel = remoteEvents:WaitForChild("ChangeCarModel")

-- Cuando un jugador entra, esperar a que su personaje se cargue
-- y luego notificarle su EquipType actual
Players.PlayerAdded:Connect(function(player)
	-- Establecer Attribute inicial cuando el perfil esté listo
	task.spawn(function()
		-- Esperar a que el perfil esté cargado
		while not DataManager.Profiles[player] do
			task.wait(0.1)
		end

		local currentEquipType = DataManager.GetStat(player, "EquipType") or 1
		player:SetAttribute("EquipType", currentEquipType)
		print("[InitialEquipType] Attribute EquipType establecido para " .. player.Name .. ": " .. currentEquipType)
	end)

	player.CharacterAdded:Connect(function(character)
		-- Esperar un poco para asegurarse de que todos los scripts del cliente estén listos
		task.wait(1)

		-- Obtener el EquipType actual del jugador
		local currentEquipType = DataManager.GetStat(player, "EquipType") or 1

		-- Asegurar que el Attribute esté actualizado
		player:SetAttribute("EquipType", currentEquipType)

		-- Notificar al cliente su EquipType actual
		changeCarModel:FireClient(player, player, currentEquipType)

		print("[InitialEquipType] Notificado a " .. player.Name .. " EquipType inicial: " .. currentEquipType)
	end)
end)

print("[InitialEquipType] ✅ Sistema inicializado")
