local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DialogueDataBase = require(game.ReplicatedStorage.Modules.Data.DialogueDataBase)
local GameEvents = require(game.ReplicatedStorage.Modules.Core.GameEvents)

local DialogueService = {}

DialogueService.ActiveDialogues = {}

function DialogueService:PlayDialogue(player, dialogue, stage)
	local data = DialogueDataBase:GetDialogueData(dialogue)
	if data then
		
		local stageData = data[stage]
		
		DialogueService.ActiveDialogues[player] = {
			Dialogue = data,
			Current = stageData,
			Line = 1,
		}
		NetworkingService:FireToClient(
			player,
			"ShowDialogue",
			DialogueService.ActiveDialogues[player].Current.Speaker,
			DialogueService.ActiveDialogues[player].Current.Lines[DialogueService.ActiveDialogues[player].Line]
		)
	end
end

function DialogueService:ContinueDialogue(player)
	DialogueService.ActiveDialogues[player].Line += 1
	if DialogueService.ActiveDialogues[player].Line > #DialogueService.ActiveDialogues[player].Current.Lines then
		DialogueService:EndDialogue(player)
		
	else
		NetworkingService:FireToClient(
			player,
			"ShowDialogue",
			DialogueService.ActiveDialogues[player].Current.Speaker,
			DialogueService.ActiveDialogues[player].Current.Lines[DialogueService.ActiveDialogues[player].Line],
			DialogueService.ActiveDialogues[player].Current.Name
		)
	end
	
end

function DialogueService:NextDialogueBranch(player:Player, option)
	if option then
		if not option.Next then 
			DialogueService:EndDialogue(player)
			return
		end
		local nextDialogue = DialogueService.ActiveDialogues[player].Dialogue[option.Next]
		DialogueService.ActiveDialogues[player].Current = nextDialogue
		DialogueService.ActiveDialogues[player].Line = 1
	end
	NetworkingService:FireToClient(
		player,
		"ShowDialogue",
		DialogueService.ActiveDialogues[player].Current.Speaker,
		DialogueService.ActiveDialogues[player].Current.Lines[DialogueService.ActiveDialogues[player].Line],
		DialogueService.ActiveDialogues[player].Current.Name
	)
end

function DialogueService:SelectDialogueOption(player, optionNumber)
	if DialogueService.ActiveDialogues[player].Current then
		local option = DialogueService.ActiveDialogues[player].Current.Lines[DialogueService.ActiveDialogues[player].Line].Options[optionNumber]
		DialogueService:NextDialogueBranch(player, option)
		local action = option.Action

		if action == "AcceptQuest" then
			local questID = option.Quest
			GameEvents.AcceptQuest:Fire(player, questID)
		end	

	end
end

function DialogueService:EndDialogue(player)
	DialogueService.ActiveDialogues[player].Current = nil
	DialogueService.ActiveDialogues[player].Line = 1
	NetworkingService:FireToClient(player , "ShowDialogue", nil,nil, true)
end


return DialogueService
