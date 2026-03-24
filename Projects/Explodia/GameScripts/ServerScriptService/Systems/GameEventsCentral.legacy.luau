local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.Modules
local Services = game.ServerScriptService.Services

local MobData = require(game.ReplicatedStorage.Modules.Data.MobData)
local GameEvents = require(game.ReplicatedStorage.Modules.Core.GameEvents)

local QuestService = require(game.ServerScriptService.Services.Profile.QuestService)
local InventoryService = require(game.ServerScriptService.Services.Profile.InventoryService)
local CurrencyService =  require(game.ServerScriptService.Services.Profile.CurrencyService)
local LevelService = require(game.ServerScriptService.Services.Profile.LevelService)
local StatsService =  require(game.ServerScriptService.Services.Profile.StatService)
local RewardsService = require(game.ServerScriptService.Services.World.RewardsService)
local EquipService = require(game.ServerScriptService.Services.Profile.EquipService)
local BuffService = require(game.ServerScriptService.Services.Profile.BuffService)


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
