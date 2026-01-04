--========================================================
-- SettingsUi_DarkTech.client.lua  |  DevPanels
-- Version: V1.9  (Theme Color + Scroll + Audio Filters + FONT FIX + CLICK SOUND)
-- Creator: xBlu3_V3bxs10 (David)
--
-- UPDATE V1.9 (IMPORTANT)
--   ✅ Now runs as a standalone client script (StarterPlayerScripts)
--   ✅ Creates its own ScreenGui - no need to place inside StarterGui
--   ✅ Font selection now WORKS (Roblox fonts): "Fredoka One", "BANGERS", "Arimo"
--   ✅ A click sound now plays on EVERY UI click:
--        rbxassetid://95635059379804
--
-- WHAT THIS SCRIPT DOES
--   • Builds a Dark-Tech "Settings" UI by script (no external assets required)
--   • Smooth open/close animations
--   • Responsive scaling for mobile + safe zones
--   • Scrollable content area so nothing gets cut off
--   • Theme color actually changes accent UI parts
--   • Font selection applies to the whole Settings UI text
--
-- WHERE TO PUT IT
--   StarterPlayerScripts (as a client script)
--   OR StarterGui (as a LocalScript - will still work)
--
-- HOW IT OPENS
--   It searches for a GuiButton named "SettingsButton" anywhere in PlayerGui
--   and connects it to open the panel.
--
-- BUYER QUICK EDITS
--   • Change open button name: OPEN_BUTTON_NAME
--   • Mobile size: MOBILE_SCALE_PADDING / MIN_SCALE
--   • Enable/disable ESC close: CLOSE_WITH_ESC
--   • Audio targets (what players can mute): AUDIO_TARGETS
--========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local plr = Players.LocalPlayer
local playerGui = plr:WaitForChild("PlayerGui")

-- Reuse existing ScreenGui if it exists, otherwise create a new one
local gui = playerGui:FindFirstChild("SettingsUi")
if not gui then
	print("[SettingsUi DEBUG] Creating new ScreenGui")
	gui = Instance.new("ScreenGui")
	gui.Name = "SettingsUi"
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui
else
	print("[SettingsUi DEBUG] Found existing ScreenGui:", gui:GetFullName())
end
gui.Enabled = true
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
print("[SettingsUi DEBUG] ScreenGui configured - Enabled:", gui.Enabled)

--========================================================
-- BUYER SETTINGS (EASY TO CHANGE)
--========================================================

-- Open button name (change if your button is named differently)
local OPEN_BUTTON_NAME = "SettingsButton"

-- ESC close toggle
local CLOSE_WITH_ESC = true

-- MOBILE / SMALL SCREEN SCALE TUNING
-- Bigger padding => UI becomes smaller => safer on mobile
local MOBILE_SCALE_PADDING = 0.80  -- Try 0.75 if you want it bigger on phones
local MIN_SCALE = 0.50
local MAX_SCALE = 1.00

-- Theme demo defaults
local DEFAULT_THEME_COLOR = "Cyan"

-- Font demo defaults
local DEFAULT_FONT_NAME = "Arimo"         -- "Fredoka One" / "BANGERS" / "Arimo"
local DEFAULT_FONT_WEIGHT = "Regular"     -- Demo label only (Roblox legacy fonts have limited weight support)

-- Click sound (plays on every click)
local CLICK_SOUND_ID = "rbxassetid://95635059379804"
local CLICK_VOLUME = 0.8

--========================================================
-- AUDIO TARGETS (BUYER CUSTOMIZATION)
--========================================================
-- Players can toggle these to mute certain audio categories.
-- Recommended: use SoundGroups named "Music", "SFX", "Ambience" under SoundService.
local AUDIO_TARGETS = {
	{Label = "Mute Music",    Type = "SoundGroup", Name = "Music"},
	{Label = "Mute SFX",      Type = "SoundGroup", Name = "SFX"},
	{Label = "Mute Ambience", Type = "SoundGroup", Name = "Ambience"},

	-- Optional: target individual Sounds by Name
	-- {Label = "Mute Menu Music", Type = "SoundName", Name = "MenuMusic"},
}

--========================================================
-- THEME COLORS (Dark-Tech)
--========================================================
local BLACK    = Color3.fromRGB(0,0,0)
local BG       = Color3.fromRGB(10,10,14)
local PANEL    = Color3.fromRGB(16,16,22)
local CARD     = Color3.fromRGB(18,18,26)
local CARD_TOP = Color3.fromRGB(22,22,32)
local TEXT     = Color3.fromRGB(245,245,245)
local MUTED    = Color3.fromRGB(170,175,190)

-- Default accent (Cyan)
local ACCENT   = Color3.fromRGB(80,220,255)

local GOODTXT  = Color3.fromRGB(120,255,170)
local BADTXT   = Color3.fromRGB(255,120,120)

--========================================================
-- CLICK SOUND SYSTEM (plays on every click)
--========================================================
local clickSound = Instance.new("Sound")
clickSound.Name = "DevPanels_Click"
clickSound.SoundId = CLICK_SOUND_ID
clickSound.Volume = CLICK_VOLUME
clickSound.Parent = gui

local function playClick()
	-- Reset so fast repeated clicks still play
	clickSound.TimePosition = 0
	clickSound:Play()
end

--========================================================
-- FONT SYSTEM (FIX)
--========================================================
-- Buyers: these are Roblox built-in fonts via Enum.Font.
-- If your Studio version doesn't include one of them, switch it to another Enum.Font.
local FONT_MAP = {
	["Fredoka One"] = Enum.Font.FredokaOne,
	["BANGERS"]     = Enum.Font.Bangers,
	["Arimo"]       = Enum.Font.Arimo, -- Roblox has Enum.Font.Arimo on modern builds
}

-- We collect every text object so we can apply the selected font to the whole UI.
local TEXT_OBJECTS = {}

local function registerTextObject(obj)
	if obj and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
		table.insert(TEXT_OBJECTS, obj)
	end
end

local function applyFontToAll(fontName, fontWeight)
	-- fontWeight is kept for buyers (demo). Roblox legacy Enum.Font has limited real weight control.
	-- If you want "real weight", buyers can implement FontFace later.
	local f = FONT_MAP[fontName] or Enum.Font.Arimo

	for _, obj in ipairs(TEXT_OBJECTS) do
		if obj and obj.Parent then
			obj.Font = f
			-- Optional light "weight feel":
			-- Bold -> keep stroke visible
			-- Thin -> hide stroke more
			if fontWeight == "Thin" then
				obj.TextStrokeTransparency = 0.35
			elseif fontWeight == "Bold" then
				obj.TextStrokeTransparency = 0
			else
				obj.TextStrokeTransparency = 0
			end
		end
	end
end

--========================================================
-- THEME COLOR SYSTEM (FIX)
--========================================================
local CURRENT_ACCENT = ACCENT

local THEME_COLOR_MAP = {
	Cyan   = Color3.fromRGB(80,220,255),
	Purple = Color3.fromRGB(180,120,255),
	Green  = Color3.fromRGB(120,255,170),
	Orange = Color3.fromRGB(255,170,80),
	Red    = Color3.fromRGB(255,120,120),
}

local THEME_OBJECTS = {
	AccentFrames  = {}, -- knobs, dots, etc.
	AccentFills   = {}, -- slider fills
	AccentButtons = {}, -- apply button etc.
}

local function registerAccentFrame(obj) table.insert(THEME_OBJECTS.AccentFrames, obj) end
local function registerAccentFill(obj)  table.insert(THEME_OBJECTS.AccentFills, obj)  end
local function registerAccentButton(obj) table.insert(THEME_OBJECTS.AccentButtons, obj) end

local function applyThemeColor(themeName)
	local c = THEME_COLOR_MAP[themeName] or THEME_COLOR_MAP.Cyan
	CURRENT_ACCENT = c

	for _, obj in ipairs(THEME_OBJECTS.AccentFrames) do
		if obj and obj.Parent then obj.BackgroundColor3 = c end
	end
	for _, obj in ipairs(THEME_OBJECTS.AccentFills) do
		if obj and obj.Parent then obj.BackgroundColor3 = c end
	end
	for _, obj in ipairs(THEME_OBJECTS.AccentButtons) do
		if obj and obj.Parent then obj.BackgroundColor3 = c end
	end
end

--========================================================
-- UI HELPERS
--========================================================
local function corner(parent, px)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, px)
	c.Parent = parent
	return c
end

local function stroke(parent, thick, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness = thick
	s.Color = BLACK
	s.Transparency = transparency or 0
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = parent
	return s
end

local function outlineText(obj)
	if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
		obj.TextStrokeTransparency = 0
		obj.TextStrokeColor3 = BLACK
	end
end

local function applyButtonFX(btn, hoverScl, clickScl)
	hoverScl = hoverScl or 1.06
	clickScl = clickScl or 0.92

	local origSize = btn.Size
	local tInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	local function tweenToScale(scl)
		local newSize = UDim2.new(
			origSize.X.Scale * scl, origSize.X.Offset * scl,
			origSize.Y.Scale * scl, origSize.Y.Offset * scl
		)
		return TweenService:Create(btn, tInfo, {Size = newSize})
	end

	btn.MouseEnter:Connect(function()
		tweenToScale(hoverScl):Play()
	end)
	btn.MouseLeave:Connect(function()
		tweenToScale(1):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		playClick()
		task.spawn(function()
			local t = tweenToScale(clickScl)
			t:Play()
			t.Completed:Wait()
			tweenToScale(1):Play()
		end)
	end)

	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			playClick()
			tweenToScale(clickScl):Play()
		end
	end)
	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			tweenToScale(1):Play()
		end
	end)
end

--========================================================
-- ROOT LAYERS: dim + main panel
--========================================================
local dim = Instance.new("Frame")
dim.Name = "Dim"
dim.Size = UDim2.fromScale(1,1)
dim.BackgroundColor3 = BLACK
dim.BackgroundTransparency = 1
dim.Visible = false
dim.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "MainSettings"
panel.AnchorPoint = Vector2.new(0.5,0.5)
panel.Position = UDim2.fromScale(0.5,0.5)
panel.Size = UDim2.new(0, 1050, 0, 650)
panel.BackgroundColor3 = BG
panel.BackgroundTransparency = 1
panel.Visible = false
panel.Parent = gui
corner(panel, 26)
stroke(panel, 3, 0)

local softOuter = Instance.new("UIStroke")
softOuter.Thickness = 10
softOuter.Color = BLACK
softOuter.Transparency = 0.75
softOuter.LineJoinMode = Enum.LineJoinMode.Round
softOuter.Parent = panel

--========================================================
-- HEADER
--========================================================
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1,0,0,70)
header.BackgroundColor3 = PANEL
header.BackgroundTransparency = 1
header.Parent = panel
corner(header, 26)
stroke(header, 2, 0)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 18, 0, 6)
title.Size = UDim2.new(1, -160, 0, 30)
title.Font = Enum.Font.GothamBlack
title.TextSize = 28
title.TextColor3 = TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "⚙ SETTINGS"
title.Parent = header
outlineText(title)
registerTextObject(title)

local sub = Instance.new("TextLabel")
sub.Name = "Subtitle"
sub.BackgroundTransparency = 1
sub.Position = UDim2.new(0, 20, 0, 38)
sub.Size = UDim2.new(1, -160, 0, 20)
sub.Font = Enum.Font.GothamBold
sub.TextSize = 14
sub.TextColor3 = MUTED
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Text = "Customize your game experience"
sub.Parent = header
outlineText(sub)
registerTextObject(sub)

-- Close (Icon Button) - TOP RIGHT (fixed border sizing)
local closeHolder = Instance.new("Frame")
closeHolder.Name = "CloseHolder"
closeHolder.Size = UDim2.new(0, 56, 0, 44)
closeHolder.Position = UDim2.new(1, -74, 0.5, -22)
closeHolder.BackgroundTransparency = 1
closeHolder.Parent = header
corner(closeHolder, 14)

-- Border frame (stroke stays inside visually)
local closeBorder = Instance.new("Frame")
closeBorder.Name = "Border"
closeBorder.Size = UDim2.fromScale(1, 1)
closeBorder.BackgroundTransparency = 1
closeBorder.Parent = closeHolder
corner(closeBorder, 14)

local borderStroke = Instance.new("UIStroke")
borderStroke.Thickness = 2
borderStroke.Color = BLACK
borderStroke.Transparency = 0
borderStroke.LineJoinMode = Enum.LineJoinMode.Round
borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- IMPORTANT: keeps it on the border
borderStroke.Parent = closeBorder

-- Actual clickable image button (no stroke here!)
local closeBtn = Instance.new("ImageButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.fromScale(1, 1)
closeBtn.BackgroundTransparency = 1
closeBtn.AutoButtonColor = false
closeBtn.Image = ""
closeBtn.ImageTransparency = 0
closeBtn.ScaleType = Enum.ScaleType.Fit
closeBtn.Parent = closeHolder

-- Add padding so icon doesn't touch edges
local iconPad = Instance.new("UIPadding")
iconPad.PaddingLeft = UDim.new(0, 8)
iconPad.PaddingRight = UDim.new(0, 8)
iconPad.PaddingTop = UDim.new(0, 6)
iconPad.PaddingBottom = UDim.new(0, 6)
iconPad.Parent = closeBtn

-- Hover/click animation + click sound
applyButtonFX(closeBtn, 1.06, 0.92)

closeBtn.MouseButton1Click:Connect(function()
	playClick()
	closeUI()
end)


--========================================================
-- BODY CARD
--========================================================
local body = Instance.new("Frame")
body.Name = "Body"
body.BackgroundColor3 = CARD
body.BackgroundTransparency = 0
body.Position = UDim2.new(0, 18, 0, 86)
body.Size = UDim2.new(1, -36, 1, -104)
body.Parent = panel
corner(body, 22)
stroke(body, 2, 0)

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.BackgroundColor3 = CARD_TOP
topBar.BackgroundTransparency = 0
topBar.Size = UDim2.new(1, 0, 0, 54)
topBar.Parent = body
corner(topBar, 22)
stroke(topBar, 2, 0)

local topLabel = Instance.new("TextLabel")
topLabel.Name = "TopLabel"
topLabel.BackgroundTransparency = 1
topLabel.Position = UDim2.new(0, 16, 0, 0)
topLabel.Size = UDim2.new(1, -32, 1, 0)
topLabel.Font = Enum.Font.GothamBlack
topLabel.TextSize = 18
topLabel.TextColor3 = TEXT
topLabel.TextXAlignment = Enum.TextXAlignment.Left
topLabel.Text = "SETTINGS"
topLabel.Parent = topBar
outlineText(topLabel)
registerTextObject(topLabel)

--========================================================
-- SCROLLING CONTENT (MOBILE FIX)
--========================================================
local bottomHeight = 64

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Scroll"
scroll.BackgroundTransparency = 1
scroll.Position = UDim2.new(0, 0, 0, 54)
scroll.Size = UDim2.new(1, 0, 1, -(54 + bottomHeight))
scroll.ScrollBarThickness = 8
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ElasticBehavior = Enum.ElasticBehavior.Always
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = body

local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundTransparency = 1
content.Size = UDim2.new(1, 0, 0, 0)
content.Parent = scroll

local contentPad = Instance.new("UIPadding")
contentPad.PaddingTop = UDim.new(0, 16)
contentPad.PaddingBottom = UDim.new(0, 16)
contentPad.Parent = content

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

--========================================================
-- SECTION BUILDERS (using "content")
--========================================================
local function makeSectionHeader(parent, text)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -32, 0, 20)
	lbl.Position = UDim2.new(0, 16, 0, 0)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 16
	lbl.TextColor3 = MUTED
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = text
	lbl.Parent = parent
	outlineText(lbl)
	registerTextObject(lbl)
	return lbl
end

local function makeRowCard(parent, h)
	local card = Instance.new("Frame")
	card.BackgroundColor3 = Color3.fromRGB(14,14,18)
	card.BackgroundTransparency = 0
	card.Size = UDim2.new(1, -32, 0, h)
	card.Position = UDim2.new(0, 16, 0, 0)
	card.Parent = parent
	corner(card, 18)
	stroke(card, 2, 0)
	return card
end

local function makeSectionBlock(titleText, cardHeight)
	local block = Instance.new("Frame")
	block.Name = titleText .. "_Block"
	block.BackgroundTransparency = 1
	block.Size = UDim2.new(1, 0, 0, cardHeight + 26)
	block.Parent = content

	makeSectionHeader(block, titleText)

	local card = makeRowCard(block, cardHeight)
	card.Position = UDim2.new(0, 16, 0, 26)
	return block, card
end

--========================================================
-- AUDIO SECTION (2 sliders)
--========================================================
local _, audioCard = makeSectionBlock("AUDIO", 90)

local function makeSlider(parent, name, xScale, labelText)
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.new(xScale, 0, 0, 0)
	holder.Size = UDim2.new(0.5, 0, 1, 0)
	holder.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 16, 0, 10)
	lbl.Size = UDim2.new(1, -32, 0, 20)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 18
	lbl.TextColor3 = TEXT
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = labelText
	lbl.Parent = holder
	outlineText(lbl)
	registerTextObject(lbl)

	local bar = Instance.new("Frame")
	bar.Name = name .. "_Bar"
	bar.BackgroundColor3 = Color3.fromRGB(40,40,52)
	bar.Position = UDim2.new(0, 16, 0, 48)
	bar.Size = UDim2.new(1, -32, 0, 10)
	bar.Parent = holder
	corner(bar, 99)
	stroke(bar, 1, 0.2)

	local fill = Instance.new("Frame")
	fill.Name = name .. "_Fill"
	fill.BackgroundColor3 = Color3.fromRGB(18, 80, 92)
	fill.Size = UDim2.new(0.65, 0, 1, 0)
	fill.Parent = bar
	corner(fill, 99)

	local knob = Instance.new("Frame")
	knob.Name = name .. "_Knob"
	knob.BackgroundColor3 = CURRENT_ACCENT
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = UDim2.new(fill.Size.X.Scale, -9, 0.5, -9)
	knob.Parent = bar
	corner(knob, 99)
	stroke(knob, 2, 0)

	registerAccentFill(fill)
	registerAccentFrame(knob)

	return bar, fill, knob
end

local soundBar, soundFill, soundKnob = makeSlider(audioCard, "Sound", 0, "Sound")
local musicBar, musicFill, musicKnob = makeSlider(audioCard, "Music", 0.5, "Music")

local function bindSlider(bar, fill, knob)
	local dragging = false

	local function setFromX(x)
		local absPos = bar.AbsolutePosition.X
		local absSize = bar.AbsoluteSize.X
		local alpha = math.clamp((x - absPos) / absSize, 0, 1)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, -9, 0.5, -9)
		return alpha
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			playClick()
			dragging = true
			setFromX(input.Position.X)
		end
	end)

	bar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			setFromX(input.Position.X)
		end
	end)

	return function()
		return fill.Size.X.Scale
	end
end

local getSound = bindSlider(soundBar, soundFill, soundKnob)
local getMusic = bindSlider(musicBar, musicFill, musicKnob)

--========================================================
-- AUDIO FILTERS (Players can choose what to mute)
--========================================================
local _, filtersCard = makeSectionBlock("AUDIO FILTERS", math.max(70, (#AUDIO_TARGETS * 32) + 18))
local audioFilterStates = {}

local function makeToggleRow(parent, y, labelText)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 16, 0, y)
	lbl.Size = UDim2.new(1, -120, 0, 22)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 16
	lbl.TextColor3 = TEXT
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = labelText
	lbl.Parent = parent
	outlineText(lbl)
	registerTextObject(lbl)

	local toggle = Instance.new("TextButton")
	toggle.BackgroundColor3 = Color3.fromRGB(28,28,38)
	toggle.Size = UDim2.new(0, 64, 0, 26)
	toggle.Position = UDim2.new(1, -80, 0, y - 2)
	toggle.Text = ""
	toggle.Parent = parent
	corner(toggle, 99)
	stroke(toggle, 2, 0)

	local dot = Instance.new("Frame")
	dot.BackgroundColor3 = CURRENT_ACCENT
	dot.Size = UDim2.new(0, 20, 0, 20)
	dot.Position = UDim2.new(0, 4, 0.5, -10)
	dot.Parent = toggle
	corner(dot, 99)
	stroke(dot, 2, 0)

	registerAccentFrame(dot)

	return toggle, dot
end

local function bindToggle(btn, dot, defaultOn)
	local on = defaultOn and true or false

	local function render()
		if on then
			TweenService:Create(dot, TweenInfo.new(0.15), {Position = UDim2.new(1, -24, 0.5, -10)}):Play()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18, 80, 92)}):Play()
		else
			TweenService:Create(dot, TweenInfo.new(0.15), {Position = UDim2.new(0, 4, 0.5, -10)}):Play()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28,28,38)}):Play()
		end
	end

	btn.MouseButton1Click:Connect(function()
		playClick()
		on = not on
		render()
	end)

	render()
	return function() return on end, function(v) on = v; render() end
end

local filterGetters = {}
local filterSetters = {}

do
	local y = 10
	for i, t in ipairs(AUDIO_TARGETS) do
		local btn, dot = makeToggleRow(filtersCard, y, t.Label)
		local get, set = bindToggle(btn, dot, false)
		filterGetters[i] = get
		filterSetters[i] = set
		audioFilterStates[i] = false
		y += 32
	end
end

--========================================================
-- GRAPHICS SECTION
--========================================================
local _, graphicsCard = makeSectionBlock("GRAPHICS", 70)

local function makeToggle(parent, xScale, labelText)
	local holder = Instance.new("Frame")
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.new(xScale, 0, 0, 0)
	holder.Size = UDim2.new(0.5, 0, 1, 0)
	holder.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 16, 0, 12)
	lbl.Size = UDim2.new(1, -120, 0, 20)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 18
	lbl.TextColor3 = TEXT
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = labelText
	lbl.Parent = holder
	outlineText(lbl)
	registerTextObject(lbl)

	local toggle = Instance.new("TextButton")
	toggle.BackgroundColor3 = Color3.fromRGB(28,28,38)
	toggle.Size = UDim2.new(0, 64, 0, 28)
	toggle.Position = UDim2.new(1, -80, 0.5, -14)
	toggle.Text = ""
	toggle.Parent = holder
	corner(toggle, 99)
	stroke(toggle, 2, 0)

	local dot = Instance.new("Frame")
	dot.BackgroundColor3 = CURRENT_ACCENT
	dot.Size = UDim2.new(0, 22, 0, 22)
	dot.Position = UDim2.new(0, 4, 0.5, -11)
	dot.Parent = toggle
	corner(dot, 99)
	stroke(dot, 2, 0)

	registerAccentFrame(dot)

	return toggle, dot
end

local particlesToggle, particlesDot = makeToggle(graphicsCard, 0, "Particles")
local shadowsToggle, shadowsDot = makeToggle(graphicsCard, 0.5, "Shadows")

local function bindToggleSimple(btn, dot)
	local on = true
	local function render()
		if on then
			TweenService:Create(dot, TweenInfo.new(0.15), {Position = UDim2.new(1, -26, 0.5, -11)}):Play()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18, 80, 92)}):Play()
		else
			TweenService:Create(dot, TweenInfo.new(0.15), {Position = UDim2.new(0, 4, 0.5, -11)}):Play()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28,28,38)}):Play()
		end
	end

	btn.MouseButton1Click:Connect(function()
		playClick()
		on = not on
		render()
	end)

	render()
	return function() return on end
end

local getParticles = bindToggleSimple(particlesToggle, particlesDot)
local getShadows = bindToggleSimple(shadowsToggle, shadowsDot)

--========================================================
-- CONTROLS SECTION (UI Scale)
--========================================================
local _, controlsCard = makeSectionBlock("CONTROLS", 70)

local uiScaleLabel = Instance.new("TextLabel")
uiScaleLabel.BackgroundTransparency = 1
uiScaleLabel.Position = UDim2.new(0, 16, 0, 12)
uiScaleLabel.Size = UDim2.new(1, -32, 0, 20)
uiScaleLabel.Font = Enum.Font.GothamBlack
uiScaleLabel.TextSize = 18
uiScaleLabel.TextColor3 = TEXT
uiScaleLabel.TextXAlignment = Enum.TextXAlignment.Left
uiScaleLabel.Text = "UI Scale"
uiScaleLabel.Parent = controlsCard
outlineText(uiScaleLabel)
registerTextObject(uiScaleLabel)

local uiScaleBtn = Instance.new("TextButton")
uiScaleBtn.BackgroundColor3 = Color3.fromRGB(28,28,38)
uiScaleBtn.Size = UDim2.new(0, 260, 0, 34)
uiScaleBtn.Position = UDim2.new(1, -276, 0.5, -17)
uiScaleBtn.Text = "Auto"
uiScaleBtn.Font = Enum.Font.GothamBlack
uiScaleBtn.TextSize = 16
uiScaleBtn.TextColor3 = TEXT
uiScaleBtn.Parent = controlsCard
corner(uiScaleBtn, 12)
stroke(uiScaleBtn, 2, 0)
outlineText(uiScaleBtn)
registerTextObject(uiScaleBtn)
applyButtonFX(uiScaleBtn, 1.03, 0.96)

--========================================================
-- THEMES SECTION (Theme Color + FONT selection)
--========================================================
local _, themeCard = makeSectionBlock("THEMES", 140)

local function makeSmallLabel(parent, x, y, wScale, txt)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(x, 16, 0, y)
	lbl.Size = UDim2.new(wScale, -32, 0, 20)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 16
	lbl.TextColor3 = MUTED
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = txt
	lbl.Parent = parent
	outlineText(lbl)
	registerTextObject(lbl)
	return lbl
end

makeSmallLabel(themeCard, 0,   10, 0.5, "Theme color")
makeSmallLabel(themeCard, 0.5, 10, 0.5, "Font")
makeSmallLabel(themeCard, 0,   58, 0.5, "Font weight")

local function makeSelectBtn(parent, xScale, y, text)
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = Color3.fromRGB(28,28,38)
	btn.Size = UDim2.new(0.5, -32, 0, 30)
	btn.Position = UDim2.new(xScale, 16, 0, y)
	btn.Text = text
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = 16
	btn.TextColor3 = TEXT
	btn.Parent = parent
	corner(btn, 12)
	stroke(btn, 2, 0)
	outlineText(btn)
	registerTextObject(btn)
	applyButtonFX(btn, 1.03, 0.96)
	return btn
end

local themeColorBtn = makeSelectBtn(themeCard, 0,   28, DEFAULT_THEME_COLOR)
local fontBtn       = makeSelectBtn(themeCard, 0.5, 28, DEFAULT_FONT_NAME)
local weightBtn     = makeSelectBtn(themeCard, 0,   76, DEFAULT_FONT_WEIGHT)

-- Lists (exactly what the buyer asked)
local themeColors = {"Cyan", "Purple", "Green", "Orange", "Red"}
local fonts = {"Fredoka One", "BANGERS", "Arimo"}
local weights = {"Regular", "Bold", "Thin"}

local themeIndex, fontIndex, weightIndex = 1, 1, 1

-- Set initial indices based on defaults (so the button shows the real matching list position)
do
	for i, v in ipairs(themeColors) do if v == DEFAULT_THEME_COLOR then themeIndex = i end end
	for i, v in ipairs(fonts) do if v == DEFAULT_FONT_NAME then fontIndex = i end end
	for i, v in ipairs(weights) do if v == DEFAULT_FONT_WEIGHT then weightIndex = i end end
end

local function cycle(btn, list, idx)
	idx += 1
	if idx > #list then idx = 1 end
	btn.Text = list[idx]
	return idx
end

-- Theme color applies instantly
themeColorBtn.MouseButton1Click:Connect(function()
	themeIndex = cycle(themeColorBtn, themeColors, themeIndex)
	applyThemeColor(themeColorBtn.Text)
end)

-- Font applies instantly (FIX)
fontBtn.MouseButton1Click:Connect(function()
	fontIndex = cycle(fontBtn, fonts, fontIndex)
	applyFontToAll(fontBtn.Text, weightBtn.Text)
end)

-- Weight applies instantly (demo weight feel)
weightBtn.MouseButton1Click:Connect(function()
	weightIndex = cycle(weightBtn, weights, weightIndex)
	applyFontToAll(fontBtn.Text, weightBtn.Text)
end)

-- Apply initial theme + font after UI objects exist/registered
applyThemeColor(themeColorBtn.Text)
applyFontToAll(fontBtn.Text, weightBtn.Text)

--========================================================
-- BOTTOM BAR (fixed)
--========================================================
local bottom = Instance.new("Frame")
bottom.Name = "Bottom"
bottom.BackgroundColor3 = CARD_TOP
bottom.BackgroundTransparency = 0
bottom.Size = UDim2.new(1, 0, 0, bottomHeight)
bottom.Position = UDim2.new(0, 0, 1, -bottomHeight)
bottom.Parent = body
corner(bottom, 22)
stroke(bottom, 2, 0)

local hint = Instance.new("TextLabel")
hint.Name = "Hint"
hint.BackgroundTransparency = 1
hint.Position = UDim2.new(0, 16, 0, 0)
hint.Size = UDim2.new(1, -520, 1, 0)
hint.Font = Enum.Font.GothamBlack
hint.TextSize = 14
hint.TextColor3 = MUTED
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.TextYAlignment = Enum.TextYAlignment.Center
hint.TextTruncate = Enum.TextTruncate.AtEnd
hint.Text = "Tip: adjust settings and press Apply."
hint.Parent = bottom
outlineText(hint)
registerTextObject(hint)

local resetBtn = Instance.new("TextButton")
resetBtn.Name = "Reset"
resetBtn.Size = UDim2.new(0, 180, 0, 46)
resetBtn.Position = UDim2.new(1, -410, 0.5, -23)
resetBtn.BackgroundColor3 = Color3.fromRGB(28,28,38)
resetBtn.Text = "RESET"
resetBtn.Font = Enum.Font.GothamBlack
resetBtn.TextSize = 20
resetBtn.TextColor3 = TEXT
resetBtn.Parent = bottom
corner(resetBtn, 14)
stroke(resetBtn, 2, 0)
outlineText(resetBtn)
registerTextObject(resetBtn)
applyButtonFX(resetBtn, 1.06, 0.92)

local applyBtn = Instance.new("TextButton")
applyBtn.Name = "Apply"
applyBtn.Size = UDim2.new(0, 180, 0, 46)
applyBtn.Position = UDim2.new(1, -210, 0.5, -23)
applyBtn.BackgroundColor3 = Color3.fromRGB(18, 80, 92)
applyBtn.Text = "APPLY"
applyBtn.Font = Enum.Font.GothamBlack
applyBtn.TextSize = 20
applyBtn.TextColor3 = TEXT
applyBtn.Parent = bottom
corner(applyBtn, 14)
stroke(applyBtn, 2, 0)
outlineText(applyBtn)
registerTextObject(applyBtn)
applyButtonFX(applyBtn, 1.06, 0.92)

-- Theme accent applies to Apply button
registerAccentButton(applyBtn)
applyThemeColor(themeColorBtn.Text)

--========================================================
-- RESPONSIVE SCALE (MOBILE SUPPORT)
-- BUYERS CHANGE MOBILE SIZE HERE:
--   • MOBILE_SCALE_PADDING (top)
--   • MIN_SCALE (top)
--========================================================
local baseSize = Vector2.new(1050, 650)

local uiScale = panel:FindFirstChildOfClass("UIScale")
if not uiScale then
	uiScale = Instance.new("UIScale")
	uiScale.Parent = panel
end

local CLOSED_MULT = 0.92
local targetScale = 1

local function getSafeViewport()
	local vp = gui.AbsoluteSize
	local insetX, insetY = 0, 0

	local okInset, inset = pcall(function()
		return GuiService:GetGuiInset()
	end)
	if okInset then
		if typeof(inset) == "Vector2" or typeof(inset) == "Vector2int16" then
			insetY += inset.Y
		end
	end

	local okSafe, left, top, right, bottomOff = pcall(function()
		return GuiService:GetSafeZoneOffsets()
	end)
	if okSafe then
		insetX += (left + right)
		insetY += (top + bottomOff)
	end

	local safeW = math.max(1, vp.X - insetX)
	local safeH = math.max(1, vp.Y - insetY)
	return Vector2.new(safeW, safeH)
end

local function computeTargetScale()
	local vp = getSafeViewport()
	local sX = vp.X / baseSize.X
	local sY = vp.Y / baseSize.Y
	local s = math.min(sX, sY) * MOBILE_SCALE_PADDING
	s = math.clamp(s, MIN_SCALE, MAX_SCALE)
	return s
end

local function fitPanel()
	targetScale = computeTargetScale()
	if not panel.Visible then
		uiScale.Scale = targetScale * CLOSED_MULT
	end
end

fitPanel()
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitPanel)

--========================================================
-- OPEN/CLOSE animations
--========================================================
local function setAlpha(a)
	panel.BackgroundTransparency = a
	header.BackgroundTransparency = a

	for _, d in ipairs(panel:GetDescendants()) do
		if d:IsA("TextLabel") then d.TextTransparency = a end
		if d:IsA("TextButton") then d.TextTransparency = a; d.BackgroundTransparency = math.clamp(a,0,1) end
		if d:IsA("UIStroke") then d.Transparency = a end
	end
end

local isOpen, busy = false, false

local function openUI()
	print("[SettingsUi DEBUG] openUI() called - isOpen:", isOpen, "busy:", busy)
	if busy or isOpen then 
		print("[SettingsUi DEBUG] openUI() blocked - returning early")
		return 
	end
	busy = true
	isOpen = true
	
	print("[SettingsUi DEBUG] Opening panel...")
	print("[SettingsUi DEBUG] gui.Enabled:", gui.Enabled)
	print("[SettingsUi DEBUG] gui.Parent:", gui.Parent)
	print("[SettingsUi DEBUG] panel:", panel)
	print("[SettingsUi DEBUG] dim:", dim)

	fitPanel()

	dim.Visible = true
	panel.Visible = true
	print("[SettingsUi DEBUG] Set dim.Visible and panel.Visible to true")
	
	setAlpha(1)
	dim.BackgroundTransparency = 1

	uiScale.Scale = targetScale * CLOSED_MULT
	print("[SettingsUi DEBUG] Starting animations, targetScale:", targetScale)

	TweenService:Create(dim, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.45}):Play()
	TweenService:Create(uiScale, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = targetScale}):Play()
	TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
	TweenService:Create(header, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()

	task.delay(0.05, function()
		for _, d in ipairs(panel:GetDescendants()) do
			if d:IsA("TextLabel") then TweenService:Create(d, TweenInfo.new(0.16), {TextTransparency = 0}):Play() end
			if d:IsA("TextButton") then TweenService:Create(d, TweenInfo.new(0.16), {TextTransparency = 0, BackgroundTransparency = 0}):Play() end
			if d:IsA("UIStroke") then TweenService:Create(d, TweenInfo.new(0.16), {Transparency = 0}):Play() end
		end
	end)

	task.delay(0.30, function()
		busy = false
		print("[SettingsUi DEBUG] openUI() animation complete, busy = false")
	end)
end

local function closeUI()
	print("[SettingsUi DEBUG] closeUI() called - isOpen:", isOpen, "busy:", busy)
	if busy or not isOpen then 
		print("[SettingsUi DEBUG] closeUI() blocked - returning early")
		return 
	end
	busy = true
	isOpen = false

	for _, d in ipairs(panel:GetDescendants()) do
		if d:IsA("TextLabel") then TweenService:Create(d, TweenInfo.new(0.12), {TextTransparency = 1}):Play() end
		if d:IsA("TextButton") then TweenService:Create(d, TweenInfo.new(0.12), {TextTransparency = 1, BackgroundTransparency = 1}):Play() end
		if d:IsA("UIStroke") then TweenService:Create(d, TweenInfo.new(0.12), {Transparency = 1}):Play() end
	end

	TweenService:Create(uiScale, TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = targetScale * CLOSED_MULT}):Play()
	TweenService:Create(dim, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
	TweenService:Create(panel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
	TweenService:Create(header, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()

	task.delay(0.22, function()
		if not isOpen then
			panel.Visible = false
			dim.Visible = false
			setAlpha(1)
		end
		busy = false
	end)
end

closeBtn.MouseButton1Click:Connect(closeUI)

if CLOSE_WITH_ESC then
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if not isOpen then return end
		if input.KeyCode == Enum.KeyCode.Escape then
			playClick()
			closeUI()
		end
	end)
end

--========================================================
-- OPEN BUTTON HOOK (BUYER EDIT POINT)
--========================================================
task.spawn(function()
	print("[SettingsUi DEBUG] Starting button search for:", OPEN_BUTTON_NAME)
	-- Wait for the button to exist (may load after this script)
	local openBtn = nil
	local maxAttempts = 20
	for i = 1, maxAttempts do
		openBtn = playerGui:FindFirstChild(OPEN_BUTTON_NAME, true)
		if openBtn and openBtn:IsA("GuiButton") then
			print("[SettingsUi DEBUG] Found button on attempt", i, ":", openBtn:GetFullName())
			break
		end
		print("[SettingsUi DEBUG] Attempt", i, "- button not found, waiting...")
		task.wait(0.25)
	end
	
	if openBtn and openBtn:IsA("GuiButton") then
		print("[SettingsUi DEBUG] Connecting MouseButton1Click to button:", openBtn:GetFullName())
		openBtn.MouseButton1Click:Connect(function()
			print("[SettingsUi DEBUG] Button clicked!")
			playClick()
			openUI()
		end)
		print("[SettingsUi] Open button connected: " .. OPEN_BUTTON_NAME)
	else
		warn("[SettingsUi] Open button not found after " .. maxAttempts .. " attempts: " .. tostring(OPEN_BUTTON_NAME))
	end
end)

--========================================================
-- RESET / APPLY LOGIC
--========================================================
local function flash(text, color)
	hint.Text = text
	hint.TextColor3 = color
	task.delay(2, function()
		hint.TextColor3 = MUTED
		hint.Text = "Tip: adjust settings and press Apply."
	end)
end

local scaleModes = {"Auto", "Small", "Medium", "Large"}
local scaleIndex = 1

local function applyUiScaleMode(mode)
	if mode == "Auto" then
		uiScale.Scale = targetScale
	elseif mode == "Small" then
		uiScale.Scale = math.clamp(targetScale * 0.85, MIN_SCALE, MAX_SCALE)
	elseif mode == "Medium" then
		uiScale.Scale = math.clamp(targetScale * 0.95, MIN_SCALE, MAX_SCALE)
	elseif mode == "Large" then
		uiScale.Scale = math.clamp(targetScale * 1.05, MIN_SCALE, MAX_SCALE)
	end
end

uiScaleBtn.MouseButton1Click:Connect(function()
	scaleIndex += 1
	if scaleIndex > #scaleModes then scaleIndex = 1 end
	uiScaleBtn.Text = scaleModes[scaleIndex]
	applyUiScaleMode(uiScaleBtn.Text)
end)

-- AUDIO APPLY HELPERS
local function setSoundGroupMuted(groupName, muted, baseVolume)
	local group = SoundService:FindFirstChild(groupName)
	if group and group:IsA("SoundGroup") then
		group.Volume = muted and 0 or baseVolume
	end
end

local function setSoundsByNameMuted(soundName, muted, baseVolume)
	for _, d in ipairs(SoundService:GetDescendants()) do
		if d:IsA("Sound") and d.Name == soundName then
			d.Volume = muted and 0 or baseVolume
		end
	end
end

resetBtn.MouseButton1Click:Connect(function()
	playClick()

	-- Reset sliders
	soundFill.Size = UDim2.new(0.65, 0, 1, 0)
	soundKnob.Position = UDim2.new(0.65, -9, 0.5, -9)

	musicFill.Size = UDim2.new(0.65, 0, 1, 0)
	musicKnob.Position = UDim2.new(0.65, -9, 0.5, -9)

	-- Reset audio filters (all OFF)
	for i = 1, #AUDIO_TARGETS do
		audioFilterStates[i] = false
		if filterSetters[i] then
			filterSetters[i](false)
		end
	end

	-- Reset theme + font
	themeIndex, fontIndex, weightIndex = 1, 1, 1
	themeColorBtn.Text = themeColors[themeIndex]
	fontBtn.Text = fonts[fontIndex]
	weightBtn.Text = weights[weightIndex]

	applyThemeColor(themeColorBtn.Text)
	applyFontToAll(fontBtn.Text, weightBtn.Text)

	-- Reset UI scale
	scaleIndex = 1
	uiScaleBtn.Text = scaleModes[scaleIndex]
	applyUiScaleMode("Auto")

	flash("Settings reset.", GOODTXT)
end)

applyBtn.MouseButton1Click:Connect(function()
	-- playClick() is already handled by applyButtonFX, but we keep it safe:
	playClick()

	local soundValue = getSound()
	local musicValue = getMusic()
	local particlesOn = getParticles()
	local shadowsOn = getShadows()

	local themeColor = themeColorBtn.Text
	local fontName = fontBtn.Text
	local fontWeight = weightBtn.Text
	local uiScaleMode = uiScaleBtn.Text

	-- Read audio filter toggles
	for i = 1, #AUDIO_TARGETS do
		audioFilterStates[i] = filterGetters[i] and filterGetters[i]() or false
	end

	-- CONNECT AUDIO (buyer playground)
	setSoundGroupMuted("SFX", false, soundValue)
	setSoundGroupMuted("Music", false, musicValue)

	for i, t in ipairs(AUDIO_TARGETS) do
		local muted = audioFilterStates[i]
		if t.Type == "SoundGroup" then
			local baseVol = (t.Name == "Music") and musicValue or soundValue
			setSoundGroupMuted(t.Name, muted, baseVol)
		elseif t.Type == "SoundName" then
			setSoundsByNameMuted(t.Name, muted, musicValue)
		end
	end

	-- Theme is already live, but apply once more for safety
	applyThemeColor(themeColor)

	-- Font is live, but apply once more for safety
	applyFontToAll(fontName, fontWeight)

	print("[SettingsUi] Apply:",
		"Sound=", soundValue,
		"Music=", musicValue,
		"Particles=", particlesOn,
		"Shadows=", shadowsOn,
		"UI Scale=", uiScaleMode,
		"ThemeColor=", themeColor,
		"Font=", fontName,
		"Weight=", fontWeight
	)

	flash("Settings applied.", GOODTXT)
end)

--========================================================
-- START CLOSED
--========================================================
panel.Visible = false
dim.Visible = false
setAlpha(1)

print("[SettingsUi] Dark-Tech Settings UI running. (V1.8)  |  xBlu3_V3bxs10 (David)")
