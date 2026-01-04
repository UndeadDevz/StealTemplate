--========================================================
-- UIScaler.client.luau
-- Automatically scales UIStroke and UICorner elements based on screen resolution
-- Base resolution: 1920px width
--========================================================

task.wait(1) -- Wait for UIs to load

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Store original values to allow re-scaling on resize
local strokeData = {}
local cornerData = {}

local function getScaleFactor()
	return Workspace.CurrentCamera.ViewportSize.X / 1920
end

-- ========== UIStroke Scaling ==========
local function scaleStroke(stroke)
	if not strokeData[stroke] then
		strokeData[stroke] = stroke.Thickness
	end
	
	local baseThickness = strokeData[stroke]
	local scaleFactor = getScaleFactor()
	stroke.Thickness = baseThickness * scaleFactor
end

-- ========== UICorner Scaling ==========
local function scaleCorner(corner)
	if not cornerData[corner] then
		cornerData[corner] = corner.CornerRadius.Offset
	end
	
	local baseRadius = cornerData[corner]
	local scaleFactor = getScaleFactor()
	-- Only scale offset-based corners (not scale-based)
	if baseRadius > 0 then
		corner.CornerRadius = UDim.new(corner.CornerRadius.Scale, baseRadius * scaleFactor)
	end
end

-- ========== Auto Scale All ==========
local function autoScaleAll()
	for _, gui in ipairs(playerGui:GetDescendants()) do
		if gui:IsA("UIStroke") then
			scaleStroke(gui)
		elseif gui:IsA("UICorner") then
			scaleCorner(gui)
		end
	end
end

-- Scale new elements when added
playerGui.DescendantAdded:Connect(function(descendant)
	task.defer(function()
		if descendant:IsA("UIStroke") then
			scaleStroke(descendant)
		elseif descendant:IsA("UICorner") then
			scaleCorner(descendant)
		end
	end)
end)

-- Clean up data when elements are removed
playerGui.DescendantRemoving:Connect(function(descendant)
	if descendant:IsA("UIStroke") then
		strokeData[descendant] = nil
	elseif descendant:IsA("UICorner") then
		cornerData[descendant] = nil
	end
end)

-- Re-scale all when viewport size changes
Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	autoScaleAll()
end)

-- Initial scale
autoScaleAll()

print("[UIScaler] Running - Scale factor:", getScaleFactor())
