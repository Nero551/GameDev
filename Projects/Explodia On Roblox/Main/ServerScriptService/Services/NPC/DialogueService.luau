local ServerScriptService = game:GetService("ServerScriptService")
local QuestService = require(ServerScriptService.Services.Profile.QuestService)
local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local DialogueDataBase = require(game.ReplicatedStorage.Modules.Data.DialogueDataBase)

--? How to Build Dialogue (Guide)
--? Dialogues consist of 3 main phases (or more). Start , Middle and End
--? Main phases branch out to supporting phases.
--? Check Crystal Gathering Dialogue Data for example.
--? Check Zombie Greeting Dialogue Data after crystal gathering as well


local DialogueService = {}

DialogueService.ActiveDialogues = {}

function DialogueService:PlayDialogue(player, dialogueName, stage)
	local data = DialogueDataBase:GetDialogueData(dialogueName)
	print(data, "Nice")
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
			DialogueService.ActiveDialogues[player].Current.Lines[DialogueService.ActiveDialogues[player].Line].Text,
			DialogueService.ActiveDialogues[player].Current.Lines[DialogueService.ActiveDialogues[player].Line].Options
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
			DialogueService.ActiveDialogues[player].Current.Lines[DialogueService.ActiveDialogues[player].Line].Text,
			DialogueService.ActiveDialogues[player].Current.Lines[DialogueService.ActiveDialogues[player].Line].Options
		)
	end
end

function DialogueService:SelectDialogueOption(player, optionNumber)
	if DialogueService.ActiveDialogues[player].Current then
		local option =
			DialogueService.ActiveDialogues[player].Current.Lines[DialogueService.ActiveDialogues[player].Line].Options[optionNumber]
		DialogueService:NextDialogueBranch(player, option)
		local action = option.Action

		if action == "AcceptQuest" then
			local questID = option.Quest
			QuestService:AcceptQuest(player, questID)
		end
	end
end

function DialogueService:NextDialogueBranch(player: Player, option)
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
		DialogueService.ActiveDialogues[player].Current.Lines[DialogueService.ActiveDialogues[player].Line].Text,
		DialogueService.ActiveDialogues[player].Current.Lines[DialogueService.ActiveDialogues[player].Line].Options
	)
end

function DialogueService:EndDialogue(player)
	DialogueService.ActiveDialogues[player].Current = nil
	DialogueService.ActiveDialogues[player].Line = 1
	NetworkingService:FireToClient(player, "ShowDialogue", nil, nil, nil, true)
end

return DialogueService
