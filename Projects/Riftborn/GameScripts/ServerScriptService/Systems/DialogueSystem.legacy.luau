local repstor = game:GetService("ReplicatedStorage")
local remotes = repstor.Remotes


local DialogueService = require(script.Parent.Parent.ServerModules.DialogueService)
local QuestService = require(script.Parent.Parent.ServerModules.QuestService)

remotes.ContinueDialogue.OnServerEvent:Connect(function(player:Player)
	DialogueService:ContinueDialogue(player)
end)

remotes.SelectDialogueOption.OnServerEvent:Connect(function(player:Player,optionNumber)
	DialogueService:SelectDialogueOption(player, optionNumber)	
end)