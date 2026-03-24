local ServerScriptService = game:GetService("ServerScriptService")
local VitalsService = require(ServerScriptService.Services.Combat.VitalsService)
local CurrencyService = require(ServerScriptService.Services.Profile.CurrencyService)
local InventoryService = require(ServerScriptService.Services.Profile.InventoryService)
local LevelService = require(ServerScriptService.Services.Profile.LevelService)
local MasteryService = require(ServerScriptService.Services.Profile.MasteryService)
local RarityService = require(game.ServerScriptService.Services.World.RarityService)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)

local RewardsService = {}
function RewardsService:GiveRewards(player, Rewards, quest: boolean)
	local character = player.Character or player.CharacterAdded:Wait()
	if Rewards then
		if Rewards.MasteryEXP then
			local inHand = VitalsService:GetVital(character, "InHand")
			if ItemDataBase:GetItemData(inHand) then
				MasteryService:IncreaseMastery(player, inHand, Rewards.MasteryEXP)
			end
		end
		if Rewards.EXP then
			LevelService:IncreaseEXP(player, Rewards.EXP)
		end
		if Rewards.Yen then
			CurrencyService:CurrencyChange(player, "Yen", Rewards.Yen)
		end
		if Rewards.Fracta then
			CurrencyService:CurrencyChange(player, "Fracta", Rewards.Fracta)
		end
		if Rewards.ItemDrops then
			for item, itemInfo in pairs(Rewards.ItemDrops) do
				local _, itemID = ItemDataBase:GetItemData(item)
				if not itemID then
					warn("Invalid Item")
					return
				end
				---If It Is A Quest---
				if quest then
					InventoryService:AddItem(itemID, itemInfo.Amount, player)
				else
					---If Normal Mob Drops---
					if RarityService:CheckPity(player, itemID) then
						InventoryService:AddItem(itemID, itemInfo.Amount, player)
					elseif RarityService:Chance(player, itemID) then
						InventoryService:AddItem(itemID, itemInfo.Amount, player)
					end
				end
			end
		end
	end
end

return RewardsService
