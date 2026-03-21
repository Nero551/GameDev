local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local ItemDataBase  = ModuleLoader:Load("Shared", "ItemDataBase")
local DataService = ModuleLoader:Load("Server", "DataService")
local RarityData = ModuleLoader:Load("Shared", "RarityData")

local RarityService = {}


function RarityService:Chance(player , itemID)
	local ItemPities = DataService:GetTable(player, "ItemPity")
	local itemData = ItemDataBase:GetItemData(itemID)
	local rarity = itemData.Rarity
	local wantedRarityInfo = RarityData[rarity]
	if wantedRarityInfo then
		if math.random(1,100) < wantedRarityInfo.Weight then
			ItemPities[itemID] = nil
		    return true
		end	
	end
	return false
end

function RarityService:CheckPity(player:Player, itemID)
	local ItemPities = DataService:GetTable(player, "ItemPity")
	local itemData = ItemDataBase:GetItemData(itemID)
	local itemRarity = itemData.Rarity
	if itemRarity == "Mythical" or itemRarity == "Legendary" then
		if ItemPities then
			if ItemPities[itemID] then
				local pity = RarityData[itemRarity].Pity
				if ItemPities[itemID] >= pity then
					ItemPities[itemID] = nil
					print( itemID," ReachedPity ", ItemPities[itemID])
					return true
				else
					ItemPities[itemID] += 1
				end
			else
				ItemPities[itemID] = 1
			end
		end
	end
	return false
end

return RarityService
