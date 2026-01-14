local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)
-- CarConfigs ya no se usa para ExpBase (ahora es un stat del jugador)

-- Esperar al RemoteEvent
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local expGainedEvent = remoteEvents:WaitForChild("ExpGainedEvent")

-- IDs de Gamepasses para ZonasEXP (PLACEHOLDERS - reemplazar con IDs reales)
local ZONE_GAMEPASSES = {
	[3] = 1662827382,   -- Gamepass Zona x3
	[5] = 1662475783,   -- Gamepass Zona x5
	[9] = 1662647545,   -- Gamepass Zona x9
	[25] = 1663341363   -- Gamepass Zona x25
}

-- Caché de gamepasses por jugador
local gamePassCache = {}

-- Debounce para no spamear el prompt de compra
local purchasePromptCooldowns = {}

-- Función para verificar ownership de gamepass de zona
local function PlayerOwnsZonePass(player, zoneMult)
	local gamePassId = ZONE_GAMEPASSES[zoneMult]
	if not gamePassId or gamePassId == 0 then return false end

	local userId = player.UserId

	-- Verificar caché primero
	if gamePassCache[userId] and gamePassCache[userId][zoneMult] ~= nil then
		return gamePassCache[userId][zoneMult]
	end

	-- Verificar con API de Roblox
	local success, ownsPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, gamePassId)
	end)

	if success then
		if not gamePassCache[userId] then
			gamePassCache[userId] = {}
		end
		gamePassCache[userId][zoneMult] = ownsPass
		return ownsPass
	else
		warn("[ExpTraining] Error al verificar GamePass zona x" .. zoneMult .. ":", ownsPass)
		return false
	end
end

-- Limpiar caché cuando el jugador sale
Players.PlayerRemoving:Connect(function(player)
	gamePassCache[player.UserId] = nil
	purchasePromptCooldowns[player.UserId] = nil
end)

-- Detectar compras de gamepasses de zonas
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then return end

	-- Verificar si es uno de los gamepasses de zona
	for zoneMult, gpId in pairs(ZONE_GAMEPASSES) do
		if gpId == gamePassId then
			-- Limpiar caché para forzar re-verificación
			if gamePassCache[player.UserId] then
				gamePassCache[player.UserId][zoneMult] = nil
			end

			task.wait(1)

			-- Re-verificar ownership
			local owns = PlayerOwnsZonePass(player, zoneMult)
			if owns then
				print("🎉 " .. player.Name .. " compró zona x" .. zoneMult .. "!")
			end
			break
		end
	end
end)

-- Loop principal de entrenamiento
while true do
	task.wait(0.1)

	local zonasEXP = workspace:FindFirstChild("ZonasEXP")
	if not zonasEXP then
		task.wait(10)
		continue
	end

	for _, zona in pairs(zonasEXP:GetChildren()) do
		if not zona:IsA("BasePart") then continue end

		local parts = workspace:GetPartsInPart(zona)
		local procesados = {}

		for _, part in pairs(parts) do
			local player = Players:GetPlayerFromCharacter(part.Parent)
			if player and not procesados[player.Name] then
				procesados[player.Name] = true

				-- 1. Obtener Multiplicador de Zona
				local zonaMult = zona:GetAttribute("ExpBase") or 1

				-- [[ VERIFICACIÓN DE GAMEPASS ]] --
				local puedeUsarZona = false

				if zonaMult == 1 then
					-- La zona 1 siempre es gratis
					puedeUsarZona = true
				else
					-- Verificar si tiene el gamepass de esta zona
					if PlayerOwnsZonePass(player, zonaMult) then
						puedeUsarZona = true
					else
						-- NO TIENE EL GAMEPASS: Ofrecer compra
						local gamePassId = ZONE_GAMEPASSES[zonaMult]
						if gamePassId and gamePassId > 0 then
							-- Verificar cooldown para no spamear la ventana
							if not purchasePromptCooldowns[player.UserId] then
								purchasePromptCooldowns[player.UserId] = true

								print("🛒 Ofreciendo gamepass zona x"..zonaMult.." a "..player.Name)
								MarketplaceService:PromptGamePassPurchase(player, gamePassId)

								-- Resetear cooldown después de 5 segundos
								task.delay(5, function()
									purchasePromptCooldowns[player.UserId] = nil
								end)
							end
						end
					end
				end

				-- Si no puede usar la zona, saltamos al siguiente jugador (no damos EXP)
				if not puedeUsarZona then
					continue
				end

				-- [[ LÓGICA DE DAR EXP (Solo si pasó la verificación) ]] --
				local level = DataManager.GetStat(player, "Level") or 1
				local rebirths = DataManager.GetStat(player, "Rebirths") or 0
				local maxLevel = math.min(25 + (rebirths * 25), 375)

				if level < maxLevel then
					-- ExpBase ahora es un stat del jugador (ya no depende del coche)
					local baseExp = DataManager.GetStat(player, "ExpBase") or 1
					local rebirthMult = rebirths * 0.5 + 1
					local speedMult = DataManager.GetStat(player, "Multiplier") or 1
					local speedBoost = speedMult - 1

					local baseValue = baseExp * zonaMult * rebirthMult
					local expGanada = baseValue * (1 + speedBoost)

					DataManager.AddStat(player, "EXP", expGanada)
					DataManager.AddStat(player, "TotalEXP", expGanada)
					DataManager.CheckLevelUp(player)

					-- Notificar al cliente la EXP ganada
					expGainedEvent:FireClient(player, expGanada)
				end
			end
		end
	end
end
