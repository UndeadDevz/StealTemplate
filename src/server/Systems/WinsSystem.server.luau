--[[
	═══════════════════════════════════════════════════════════════════════
	WINS SYSTEM - Sistema de zonas de victoria
	═══════════════════════════════════════════════════════════════════════

	CÓMO CONFIGURAR UNA ZONA DE WIN:
	1. Crea una Part en el Workspace
	2. Agrega el Tag "WinZone" usando el Tag Editor
	3. Configura los atributos:
	   - Wins (number): Cantidad de wins que da (por defecto: 1)
	   - IsPremium (boolean): Si es zona premium que requiere compra (por defecto: false)

	ZONAS PREMIUM:
	- Si IsPremium = true, el jugador debe comprar el producto "x2 wins" cada vez que toque la zona
	- Al comprar, recibe las wins y se teleporta al spawn
	- Cada vez que vuelva a pasar, debe comprar nuevamente (producto consumible)

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Referencia al DataManager
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- ========== CONFIGURACIÓN ==========
local TAG_WIN_ZONE = "WinZone"
local X2_WINS_PRODUCT_ID = 3505110469 -- ⚠️ REEMPLAZAR CON EL ID REAL DEL PRODUCTO "x2 wins"
-- ===================================

-- Tabla para almacenar las compras pendientes (zona -> player)
local pendingPurchases = {}

-- Función para enviar al jugador al Spawn
local function TeleportToSpawn(player)
	local character = player.Character
	if character then
		-- Busca el SpawnLocation por defecto de Roblox
		local spawn = workspace:FindFirstChild("SpawnLocation")

		local targetCFrame
		if spawn and spawn:IsA("BasePart") then
			-- Si existe spawn, ir encima de él
			targetCFrame = spawn.CFrame + Vector3.new(0, 5, 0)
		else
			-- Si no hay spawn, ir al centro del mapa
			targetCFrame = CFrame.new(0, 50, 0)
			warn("[WinsSystem] No se encontró SpawnLocation, enviando a 0,50,0")
		end

		-- Teletransportar
		character:PivotTo(targetCFrame)
	end
end

-- Función para dar wins al jugador (llamada desde MarketplaceManager)
function _G.GivePremiumWins(player, winsAmount)
	if not player or not player.Parent then
		return
	end

	-- Dar Wins
	DataManager.AddStat(player, "Wins", winsAmount)
	print("🏆 " .. player.Name .. " recibió " .. winsAmount .. " Win(s) premium!")

	-- Teletransportar al Spawn
	TeleportToSpawn(player)
end

-- Configura cada zona de win
local function SetupZone(zona)
	if not zona:IsA("BasePart") then
		warn("[WinsSystem] ⚠️ El objeto con tag 'WinZone' no es una BasePart:", zona:GetFullName())
		return
	end

	-- Tabla para evitar que se active muchas veces seguidas (Debounce)
	local cooldowns = {}

	zona.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)

		if player then
			-- Si el jugador está en cooldown, no hacer nada
			if cooldowns[player] then
				return
			end

			-- Activar cooldown temporalmente
			cooldowns[player] = true

			-- Verificar si la zona es premium
			local isPremium = zona:GetAttribute("IsPremium") or false
			local winsAmount = zona:GetAttribute("Wins") or 1

			if isPremium then
				if X2_WINS_PRODUCT_ID == 0 then
					warn("[WinsSystem] ⚠️ X2_WINS_PRODUCT_ID no está configurado!")
					task.wait(1)
					cooldowns[player] = nil
					return
				end

				print("💎 " .. player.Name .. " tocó zona premium - Mostrando prompt de compra")

				-- Guardar la cantidad de wins para cuando compre
				pendingPurchases[player.UserId] = winsAmount

				-- Mostrar prompt de compra
				task.spawn(function()
					local success, err = pcall(function()
						MarketplaceService:PromptProductPurchase(player, X2_WINS_PRODUCT_ID)
					end)

					if not success then
						warn("[WinsSystem] Error al mostrar prompt de compra:", err)
					end
				end)

				-- Liberar cooldown rápido
				task.wait(1)
				cooldowns[player] = nil
			else
				-- Zona normal - dar wins directamente
				DataManager.AddStat(player, "Wins", winsAmount)
				print("🏆 " .. player.Name .. " recibió " .. winsAmount .. " Win(s)!")

				-- Teletransportar al Spawn
				TeleportToSpawn(player)

				-- Liberar cooldown
				task.wait(2)
				cooldowns[player] = nil
			end
		end
	end)

	print("[WinsSystem] ✓ Zona configurada:", zona.Name, "| Wins:", zona:GetAttribute("Wins") or 1, "| Premium:", zona:GetAttribute("IsPremium") or false)
end

-- ========== INICIALIZACIÓN ==========

-- Configurar zonas que ya existen
for _, zona in pairs(CollectionService:GetTagged(TAG_WIN_ZONE)) do
	SetupZone(zona)
end

-- Configurar nuevas zonas cuando se agreguen el tag
CollectionService:GetInstanceAddedSignal(TAG_WIN_ZONE):Connect(SetupZone)

-- Limpiar cuando se remueva el tag
CollectionService:GetInstanceRemovedSignal(TAG_WIN_ZONE):Connect(function(zona)
	print("[WinsSystem] ⚠️ Tag removido de:", zona.Name)
end)

-- Función global para obtener wins pendientes (usada por MarketplaceManager)
function _G.GetPendingWins(userId)
	return pendingPurchases[userId]
end

-- Función global para limpiar wins pendientes
function _G.ClearPendingWins(userId)
	pendingPurchases[userId] = nil
end

print("[WinsSystem] ✓ Sistema inicializado - Tag:", TAG_WIN_ZONE)
