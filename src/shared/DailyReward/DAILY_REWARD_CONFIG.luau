local DAILY_REWARD_CONFIG  = {

	-- Set to false to disable daily rewards (for testing)
	ENABLED = true,

	-- This key will store all players streak data (once you input your own don't change it.)
	DATASTORE_KEY = "Testing_DailyRewardDataStore",
	
	-- Total number of days for redeemable rewards (default = 7)
	MAX_DAYS = 7, 												
	
	-- Total number of seconds in-between when each daily reward is redeemable (86400 = 1 Day)
	COOLDOWN_SECONDS = 86400, 						
	
	-- if true, will reset the streak if player does not redeem reward in time for the next day
	RESET_STREAK_IF_MISSED = true,
	
	-- Reward GUI colors (CLAIMED = Green, SELECTED = White, UNCLAIMED = Dark Grey)
	STATE_COLORS = {								
		
		CLAIMED = Color3.fromRGB(87, 255, 78),
		SELECTED = Color3.fromRGB(255, 255, 255),
		UNCLAIMED = Color3.fromRGB(50, 50, 50),
		
		
	},
	
	-- Reward GUI colors (CLAIMED = Bold, SELECTED = ExtraBold, UNCLAIMED = Regular)
	STATE_FONTS = {									

		CLAIMED = Font.fromName("BuilderSans", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		SELECTED = Font.fromName("BuilderSans", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
		UNCLAIMED = Font.fromName("BuilderSans", Enum.FontWeight.Regular, Enum.FontStyle.Normal),


	},
	
	-- What each day will show on the frames
	-- reward_type: "Wins", "Speed", or "Special"
	DAY_PRESETS = {

		["Day 1"] = {
			reward_type = "Wins",
			reward_amount = 50,
			reward_text = "+50 Wins",
			reward_image_ID = "rbxassetid://82857133407630",
		},

		["Day 2"] = {
			reward_type = "Speed",
			reward_amount = 1000000,
			reward_text = "+1M Speed",
			reward_image_ID = "rbxassetid://130057163043800",
		},

		["Day 3"] = {
			reward_type = "Wins",
			reward_amount = 0, -- TODO: configurar
			reward_text = "???",
			reward_image_ID = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		},

		["Day 4"] = {
			reward_type = "Speed",
			reward_amount = 0, -- TODO: configurar
			reward_text = "???",
			reward_image_ID = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		},

		["Day 5"] = {
			reward_type = "Wins",
			reward_amount = 0, -- TODO: configurar
			reward_text = "???",
			reward_image_ID = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		},

		["Day 6"] = {
			reward_type = "Speed",
			reward_amount = 0, -- TODO: configurar
			reward_text = "???",
			reward_image_ID = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		},

		["Day 7"] = {
			reward_type = "Special",
			reward_amount = 0, -- TODO: implementar recompensa especial
			reward_text = "???",
			reward_image_ID = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		},

	}
	
	
}

return DAILY_REWARD_CONFIG 
