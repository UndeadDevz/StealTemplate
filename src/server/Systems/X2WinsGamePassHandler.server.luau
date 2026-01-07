--[[
	═══════════════════════════════════════════════════════════════════════
	X2 WINS GAMEPASS HANDLER - Servidor
	═══════════════════════════════════════════════════════════════════════

	Maneja las solicitudes de compra del GamePass x2 Wins desde el cliente.

	═══════════════════════════════════════════════════════════════════════
]]

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========== CONFIGURACIÓN ==========
local X2_WINS_GAMEPASS_ID = 1661925212 -- GamePass "x2 Wins"
-- ===================================

local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local promptX2WinsPurchase = remoteEvents:WaitForChild("PromptX2WinsPurchase")

-- Handler para cuando el cliente pide comprar el GamePass
print("[X2WinsGamePassHandler DEBUG] Conectando OnServerEvent...")
promptX2WinsPurchase.OnServerEvent:Connect(function(player)
	print("[X2WinsGamePassHandler DEBUG] 🔔 OnServerEvent recibido de:", player.Name)
	print("[X2WinsGamePassHandler DEBUG] GamePass ID configurado:", X2_WINS_GAMEPASS_ID)

	if X2_WINS_GAMEPASS_ID == 0 then
		warn("[X2WinsGamePassHandler] ⚠️ X2_WINS_GAMEPASS_ID no está configurado!")
		return
	end

	print("[X2WinsGamePassHandler] " .. player.Name .. " solicitó comprar x2 Wins GamePass")

	-- Mostrar prompt de compra
	print("[X2WinsGamePassHandler DEBUG] Llamando PromptGamePassPurchase...")
	task.spawn(function()
		local success, err = pcall(function()
			print("[X2WinsGamePassHandler DEBUG] Ejecutando MarketplaceService:PromptGamePassPurchase")
			MarketplaceService:PromptGamePassPurchase(player, X2_WINS_GAMEPASS_ID)
			print("[X2WinsGamePassHandler DEBUG] PromptGamePassPurchase ejecutado")
		end)

		if success then
			print("[X2WinsGamePassHandler] ✓ Prompt mostrado a " .. player.Name)
		else
			warn("[X2WinsGamePassHandler] ❌ Error al mostrar prompt:", err)
		end
	end)
end)
print("[X2WinsGamePassHandler DEBUG] OnServerEvent conectado")

print("[X2WinsGamePassHandler] ✓ Sistema inicializado - GamePass ID:", X2_WINS_GAMEPASS_ID)
