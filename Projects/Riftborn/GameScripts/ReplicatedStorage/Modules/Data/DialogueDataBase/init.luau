local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local DialogueDataBase = {}

DialogueDataBase.Sources = {}

for _,type in script.Parent:GetChildren() do
	if type:IsA("Folder") then
		DialogueDataBase.Sources[type] = {}

		for _, dialogue in type:GetChildren() do
			if dialogue:IsA("ModuleScript") then
				table.insert(DialogueDataBase.Sources[type], dialogue)
			end
		end
	end
end

function DialogueDataBase:GetDialogueData(Dialogue)
	for _, category in pairs(DialogueDataBase.Sources) do
		for _,dialogue:ModuleScript? in pairs(category) do

			if dialogue.Name == Dialogue then
				local DialogueData = ModuleLoader:Load("Shared", dialogue.Name)
				return DialogueData
			end
		end
	end
	return
end

return DialogueDataBase
