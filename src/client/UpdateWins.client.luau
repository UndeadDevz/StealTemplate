--[[
	═══════════════════════════════════════════════════════════════════════
	UPDATE WINS
	═══════════════════════════════════════════════════════════════════════
	
	Actualiza el TextLabel que muestra las victorias del jugador.
	Ubicación: Buttons > WinsCounter > WinsCount
	
	═══════════════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local buttonsGui = playerGui:WaitForChild("Buttons")
local winsCounter = buttonsGui:WaitForChild("WinsCounter")
local label = winsCounter:WaitForChild("WinsCount")

-- Function to update the text
local function UpdateText(value)
	label.Text = value 
end

-- Wait for leaderstats and Wins to load
local leaderstats = player:WaitForChild("leaderstats")
local winsStat = leaderstats:WaitForChild("Wins")

-- Update immediately when the game starts
UpdateText(winsStat.Value)

-- Update automatically whenever the value changes
winsStat.Changed:Connect(UpdateText)

print("✅ UpdateWins inicializado")
