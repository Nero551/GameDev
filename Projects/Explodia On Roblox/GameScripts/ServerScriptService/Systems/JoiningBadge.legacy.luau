local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")

local BADGE_ID = 2169905482088502

Players.PlayerAdded:Connect(function(player)
	local success, hasBadge = pcall(function()
		return BadgeService:UserHasBadgeAsync(player.UserId, BADGE_ID)
	end)

	if success and not hasBadge then
		pcall(function()
			BadgeService:AwardBadge(player.UserId, BADGE_ID)
		end)
	end
end)
