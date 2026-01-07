local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService") -- Necesario para pedir compra
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- Esperar al RemoteEvent
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local expGainedEvent = remoteEvents:WaitForChild("ExpGainedEvent")

-- Mapa inverso: Saber qué ID comprar según el multiplicador de la zona
local ZONE_PRODUCTS = {
	[3] = 3503497564,
	[5] = 3503499104,
	[9] = 3503499344,
	[25] = 3503499623
}

-- Debounce para no spamear el prompt de compra
local purchasePromptCooldowns = {}

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
				
				-- [[ VERIFICACIÓN DE COMPRA ]] --
				local puedeUsarZona = false
				
				if zonaMult == 1 then
					-- La zona 1 siempre es gratis
					puedeUsarZona = true
				else
					-- Verificar si tiene desbloqueada esta zona en DataManager
					local tracks = DataManager.GetStat(player, "Tracks") or {}
					
					-- Buscar si tiene el valor (ej. 3, 5, etc) en su tabla Tracks
					if table.find(tracks, zonaMult) then
						puedeUsarZona = true
					else
						-- NO TIENE LA ZONA: Ofrecer compra
						local productId = ZONE_PRODUCTS[zonaMult]
						if productId then
							-- Verificar cooldown para no spamear la ventana
							if not purchasePromptCooldowns[player.UserId] then
								purchasePromptCooldowns[player.UserId] = true
								
								print("🛒 Ofreciendo zona x"..zonaMult.." a "..player.Name)
								MarketplaceService:PromptProductPurchase(player, productId)
								
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
					local baseExp = DataManager.GetStat(player, "EquipType") or 1
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