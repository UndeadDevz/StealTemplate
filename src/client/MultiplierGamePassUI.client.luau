--[[
	═══════════════════════════════════════════════════════════════════════
	MULTIPLIER GAMEPASS UI - Cliente
	═══════════════════════════════════════════════════════════════════════

	Este script maneja la visualización de GamePasses de multiplicador
	disponibles y permite al jugador comprarlos.

	Los GamePasses se STACKEAN (suman):
	- Si tienes x2 + x4 + x8 = 14x total

	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Esperar a los RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local promptMultiplierPurchase = remoteEvents:WaitForChild("PromptMultiplierPurchase")

-- Lista de GamePasses de multiplicador
local MULTIPLIER_GAMEPASSES = {
	{ ID = 1661939202, Value = 2, Name = "x2 Speed" },
	{ ID = 1661865221, Value = 4, Name = "x4 Speed" },
	{ ID = 1659993882, Value = 8, Name = "x8 Speed" },
	{ ID = 1662049180, Value = 16, Name = "x16 Speed" },
	{ ID = 1660305540, Value = 32, Name = "x32 Speed" },
	{ ID = 1663886754, Value = 64, Name = "x64 Speed" },
	{ ID = 1663886755, Value = 128, Name = "x128 Speed" },
	{ ID = 1661041459, Value = 256, Name = "x256 Speed" },
}

-- Función para comprar un GamePass de multiplicador
local function PurchaseMultiplierGamePass(gamePassId)
	-- Asegurar que sea número
	local numericId = tonumber(gamePassId)

	if not numericId then
		warn("[MultiplierGamePassUI] gamePassId no es un número válido:", gamePassId)
		return
	end

	promptMultiplierPurchase:FireServer(numericId)
end

-- Exportar función globalmente para uso en botones UI (opcional)
_G.PurchaseMultiplierGamePass = PurchaseMultiplierGamePass
_G.MULTIPLIER_GAMEPASSES = MULTIPLIER_GAMEPASSES

print("[MultiplierGamePassUI] ✅ Sistema inicializado")
