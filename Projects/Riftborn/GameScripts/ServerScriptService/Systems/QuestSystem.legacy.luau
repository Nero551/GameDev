local players = game:GetService("Players")
local repstor = game:GetService("ReplicatedStorage")
local remotes  =  repstor.Remotes
local QuestService = require(script.Parent.Parent.ServerModules.QuestService)
local QuestData = require(repstor.Modules.Data.QuestData)

-----------------------------------------------------------------------------------------------------------------------------
players.PlayerAdded:Connect(function(player)

end)

-----------------------------------------------------------------------------------------------------------------------------
remotes.AcceptQuest.OnServerEvent:Connect(function(player, QuestName)
end)


-----------------------------------------------------------------------------------------------------------------------------
remotes.AbandonQuest.OnServerEvent:Connect(function(player, questName)
	local questID = QuestData:GetQuestID(questName)
	QuestService:AbandonQuest(player, questID)
end)


-----------------------------------------------------------------------------------------------------------------------------
remotes.TrackQuest.OnServerEvent:Connect(function(player:Player, questName)
	local questID = QuestData:GetQuestID(questName)
	QuestService:TrackQuest(player, questID)
end)


-----------------------------------------------------------------------------------------------------------------------------