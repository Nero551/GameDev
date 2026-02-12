local repstor = game:GetService("ReplicatedStorage")
local modules = repstor.Modules
local serverModules = script.Parent.Parent.ServerModules

local GameEvents = require(modules.GameEvents)
local DataService = require(serverModules.DataService)
local QuestService = require(serverModules.QuestService)
local InventoryService = require(serverModules.InventoryService)
local CurrencyService =  require(serverModules.CurrencyService)
local LevelService = require(serverModules.LevelService)
local RarityService = require(serverModules.RarityService)
local StatsService =  require(serverModules.StatService)
local ManaService = require(serverModules.ManaService)
local RewardsService = require(serverModules.RewardsService)
local EquipService = require(serverModules.EquipService)
local BuffService = require(serverModules.BuffService)


GameEvents.AddBuff.Event:Connect(function(player, data, ID)
	BuffService:AddBuff(player, data, ID)
end)

GameEvents.RemoveBuff.Event:Connect(function(player,  data, ID)
	BuffService:RemoveBuff(player,  data, ID)
end)

GameEvents.ResetBuffs.Event:Connect(function(player)
	StatsService:ResetBuffs(player)
end)

GameEvents.UpdateMana.Event:Connect(function(player)
	ManaService:UpdateMana(player)
end)

GameEvents.ItemChanged.Event:Connect(function(player)
	QuestService:ProgressQuest(player)
end)

GameEvents.UnEquipItem.Event:Connect(function(player, itemID)
	EquipService:UnEquipItem(player,itemID)
end)

GameEvents.MobKilled.Event:Connect(function(player, mobKilled)
	QuestService:ProgressQuest(player, mobKilled)
end)

GameEvents.AddItem.Event:Connect(function( itemID, itemType, amount, player)
	InventoryService:AddItem( itemID, itemType, amount, player)
end)

GameEvents.RemoveItem.Event:Connect(function(itemID  ,amount, player)
	InventoryService:RemoveItem( itemID  ,amount, player)
end)

GameEvents.CurrencyChange.Event:Connect(function(player, currency, amount)
	CurrencyService:CurrencyChange(player,currency, amount)
end)

GameEvents.IncreaseEXP.Event:Connect(function(player,EXP)
	LevelService:IncreaseEXP(player,  EXP)
end)

GameEvents.GiveRewards.Event:Connect(function(player, rewards, quest)
	RewardsService:GiveRewards(player, rewards, quest)
end)

GameEvents.AcceptQuest.Event:Connect(function(player,questID)
	QuestService:AcceptQuest(player,questID)
end)
