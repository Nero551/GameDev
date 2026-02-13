local RarityService = require(script.Parent.RarityService)
local GameEvents = require(game.ReplicatedStorage.Modules.GameEvents)
local itemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)

local RewardsService = {}
function RewardsService:GiveRewards(player, Rewards, quest:boolean)
	
	if Rewards then
		if Rewards.EXP then
			GameEvents.IncreaseEXP:Fire(player, Rewards.EXP)
		end
		if Rewards.Yen then
			GameEvents.CurrencyChange:Fire(player, "Yen", Rewards.Yen)
		end
		if Rewards.Fracta then
			GameEvents.CurrencyChange:Fire(player, "Fracta", Rewards.Fracta)
		end
		if Rewards.ItemDrops then
			for item, itemInfo in pairs(Rewards.ItemDrops) do
				local itemData,itemID = itemDataBase:GetItemData(item)
				---If It Is A Quest---
				if quest then
					GameEvents.AddItem:Fire(itemID  , itemInfo.Amount, player)
				else
					---If Normal Mob Drops---
					if RarityService:Chance(player , itemID) then
						
						GameEvents.AddItem:Fire(itemID  , itemInfo.Amount, player)
					else
						if RarityService:CheckPity(player, itemID) then
							GameEvents.AddItem:Fire( itemID , itemInfo.Amount, player)
						end
					end
				end
			end
		end
	end
end


return RewardsService
