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
promptX2WinsPurchase.OnServerEvent:Connect(function(player)
	if X2_WINS_GAMEPASS_ID == 0 then
		warn("[X2WinsGamePassHandler] X2_WINS_GAMEPASS_ID no está configurado!")
		return
	end

	-- Mostrar prompt de compra
	task.spawn(function()
		local success, err = pcall(function()
			MarketplaceService:PromptGamePassPurchase(player, X2_WINS_GAMEPASS_ID)
		end)

		if not success then
			warn("[X2WinsGamePassHandler] Error al mostrar prompt:", err)
		end
	end)
end)

print("[X2WinsGamePassHandler] ✓ Sistema inicializado - GamePass ID:", X2_WINS_GAMEPASS_ID)
