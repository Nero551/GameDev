local itemDataBase  = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local DataService = require(script.Parent.Parent.Services.DataService)

local RarityService = {}
RarityService.Rarities = {
	Common = {
		Weight = 100,
		Color = "#d6d6d6"
	},
	Uncommon = {
		Weight = 50,
		Color = "#20ff1c"
	},
	Rare = {
		Weight = 20,
		Color = "#18aeff"
	},
	Epic = {
		Weight = 10,
		Color = "#bd22ff"
	},
	Legendary = {
		Weight  = 5,
		Color = "#ffa618",
		Pity = 20
	},
	Mythical  = {
		Weight = 1,
		Color = "#ff2f71",
		Pity = 100
		
	}
}

function RarityService:Chance(player , itemID)
	local ItemPities = DataService:GetTable(player, "ItemPity")
	local itemData = itemDataBase:GetItemData(itemID)
	local rarity = itemData.Rarity
	local wantedRarityInfo = RarityService.Rarities[rarity]
	if wantedRarityInfo then
		if math.random(1,100) < wantedRarityInfo.Weight then
			ItemPities[itemID] = nil
		    return true
		else
			return false
		end	
	end
end

function RarityService:CheckPity(player:Player, itemID)
	local ItemPities = DataService:GetTable(player, "ItemPity")
	local itemData = itemDataBase:GetItemData(itemID)
	local itemRarity = itemData.Rarity
	if itemRarity == "Mythical" or itemRarity == "Legendary" then
		if ItemPities then
			if ItemPities[itemID] then
				if ItemPities[itemID] == itemRarity.Pity then
					ItemPities[itemID] = nil
					print( itemID," ReachedPity ", ItemPities[itemID])
					return true
				else
					ItemPities[itemID] += 1
					print(itemID," Increased Pity ", ItemPities[itemID] )
					return false
				end
			else
				ItemPities[itemID] = 1
				print(itemID," Increased Pity ", ItemPities[itemID] )
				return false
			end
		end
	end
	
end

return RarityService
