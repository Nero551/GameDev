local RarityData = require(game.ReplicatedStorage.Modules.Data.RarityData)

local RarityService = {}


function RarityService:Chance(player , rarity)
	local wantedRarityInfo = RarityData[rarity]
	if wantedRarityInfo then
		if math.random(1,100) < wantedRarityInfo.Weight then
		    return true
		end	
	end
	return false
end

return RarityService
