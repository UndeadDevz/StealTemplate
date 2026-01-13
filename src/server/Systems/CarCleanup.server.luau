--[[
	CarCleanup.server.luau
	Limpia vehículos y conductores huérfanos cuando un jugador se desconecta
]]

local Players = game:GetService("Players")

-- Limpiar objetos del jugador cuando se va
Players.PlayerRemoving:Connect(function(player)
	local playerName = player.Name

	-- Buscar y destruir coches del jugador
	for _, obj in pairs(workspace:GetChildren()) do
		-- Los coches tienen el nombre del modelo original (ej: "CocheMesh")
		-- pero contienen un conductor con el nombre del jugador
		if obj:IsA("Model") then
			local conductor = obj:FindFirstChild(playerName)
			if conductor and conductor:FindFirstChild("Humanoid") then
				print("[CarCleanup] Destruyendo coche de " .. playerName)
				obj:Destroy()
			end
		end
	end

	-- También limpiar el personaje si quedó
	if player.Character and player.Character.Parent then
		player.Character:Destroy()
	end
end)

-- Limpieza periódica de coches huérfanos (jugadores que ya no existen)
task.spawn(function()
	while true do
		task.wait(30) -- Cada 30 segundos

		local playerNames = {}
		for _, player in pairs(Players:GetPlayers()) do
			playerNames[player.Name] = true
		end

		for _, obj in pairs(workspace:GetChildren()) do
			if obj:IsA("Model") then
				-- Buscar si tiene un conductor (modelo con Humanoid dentro)
				for _, child in pairs(obj:GetChildren()) do
					if child:IsA("Model") and child:FindFirstChild("Humanoid") then
						-- Es un conductor, verificar si el jugador existe
						if not playerNames[child.Name] and child.Name ~= "Conductor" then
							print("[CarCleanup] Limpiando coche huérfano de " .. child.Name)
							obj:Destroy()
							break
						end
					end
				end
			end
		end
	end
end)

print("[CarCleanup] Sistema de limpieza inicializado")
