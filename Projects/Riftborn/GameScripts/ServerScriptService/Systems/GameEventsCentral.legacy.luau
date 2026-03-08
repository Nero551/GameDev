local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.Modules
local Services = script.Parent.Parent.Services

local MobData = require(ReplicatedStorage.Modules.Data.MobData)
local GameEvents = require(modules.GameEvents)

local QuestService = require(Services.QuestService)
local InventoryService = require(Services.InventoryService)
local CurrencyService =  require(Services.CurrencyService)
local LevelService = require(Services.LevelService)
local StatsService =  require(Services.StatService)
local RewardsService = require(Services.RewardsService)
local EquipService = require(Services.EquipService)
local BuffService = require(Services.BuffService)


GameEvents.AddBuff.Event:Connect(function(player, data, ID)
	BuffService:AddBuff(player, data, ID)
end)

GameEvents.RemoveBuff.Event:Connect(function(player,  data, ID)
	BuffService:RemoveBuff(player,  data, ID)
end)

GameEvents.ResetBuffs.Event:Connect(function(player)
	StatsService:ResetBuffs(player)
end)

GameEvents.ItemChanged.Event:Connect(function(player)
	QuestService:ProgressQuest(player)
end)

GameEvents.UnEquipItem.Event:Connect(function(player, itemID)
	EquipService:UnEquipItem(player,itemID)
end)

GameEvents.MobKilled.Event:Connect(function(player, mobKilled)
	RewardsService:GiveRewards(player, MobData.Mobs[mobKilled].Drops, false)
	QuestService:ProgressQuest(player, mobKilled)
end)

GameEvents.AddItem.Event:Connect(function( itemID, amount, player)
	InventoryService:AddItem( itemID, amount, player)
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
