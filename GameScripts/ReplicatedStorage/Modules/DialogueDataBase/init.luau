local DialogueDataBase = {}

DialogueDataBase.Sources = {
	QuestDialogues = {},
	GreetingDialogues = {},
	
}

for _,questDialogue in script.QuestsDialogue:GetChildren() do
	if questDialogue:IsA("ModuleScript") then
		table.insert(DialogueDataBase.Sources.QuestDialogues, questDialogue)
	end
end

for _,greetingDialogue in script.GreetingsDialogue:GetChildren() do
	if greetingDialogue:IsA("ModuleScript") then
		table.insert(DialogueDataBase.Sources.GreetingDialogues, greetingDialogue)
	end
end


function DialogueDataBase:GetDialogueData(Dialogue)
	for _, category in pairs(DialogueDataBase.Sources) do
		for _,dialogue:ModuleScript? in pairs(category) do

			if dialogue.Name == Dialogue then
				local data = require(dialogue)
				return data
			end
		end
	end
end

return DialogueDataBase
