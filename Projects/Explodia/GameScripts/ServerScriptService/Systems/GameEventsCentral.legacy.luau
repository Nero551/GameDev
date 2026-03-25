local ServerScriptService = game:GetService("ServerScriptService")
local NPCService = require(ServerScriptService.Services.NPC.NPCService)
local MobData = require(game.ReplicatedStorage.Modules.Data.MobData)
local GameEvents = require(game.ReplicatedStorage.Modules.Core.GameEvents)
local QuestService = require(game.ServerScriptService.Services.Profile.QuestService)
local RewardsService = require(game.ServerScriptService.Services.World.RewardsService)

GameEvents.ItemChanged.Event:Connect(function(player)
	QuestService:ProgressQuest(player)
end)

GameEvents.MobKilled.Event:Connect(function(player, mobKilled)
	local mobData = MobData.Mobs[mobKilled.Name]
	if mobData then
		RewardsService:GiveRewards(player, NPCService.SpawnedNPCS[mobData.Type][mobKilled].Drops, false)
		QuestService:ProgressQuest(player, mobKilled.Name)
	end
end)
