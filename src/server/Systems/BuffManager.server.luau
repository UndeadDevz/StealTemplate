local Players = game:GetService("Players")
local DataManager = require(script.Parent.Parent.Data.DataManager)

while true do
	task.wait(1)
	for _, player in ipairs(Players:GetPlayers()) do
		local speedRemaining = DataManager.GetStat(player, "SpeedPotionRemaining") or 0
		if speedRemaining > 0 then
			DataManager.UpdateStat(player, "SpeedPotionRemaining", speedRemaining - 1)
		end
		local winsRemaining = DataManager.GetStat(player, "WinsPotionRemaining") or 0
		if winsRemaining > 0 then
			DataManager.UpdateStat(player, "WinsPotionRemaining", winsRemaining - 1)
		end
	end
end