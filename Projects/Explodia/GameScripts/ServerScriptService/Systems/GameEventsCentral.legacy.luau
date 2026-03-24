local MobData = require(game.ReplicatedStorage.Modules.Data.MobData)
local GameEvents = require(game.ReplicatedStorage.Modules.Core.GameEvents)

local QuestService = require(game.ServerScriptService.Services.Profile.QuestService)
local RewardsService = require(game.ServerScriptService.Services.World.RewardsService)

GameEvents.ItemChanged.Event:Connect(function(player)
	QuestService:ProgressQuest(player)
end)

GameEvents.MobKilled.Event:Connect(function(player, mobKilled)
	if MobData.Mobs[mobKilled] then
		RewardsService:GiveRewards(player, MobData.Mobs[mobKilled].Drops, false)
		QuestService:ProgressQuest(player, mobKilled)
	end
end)
