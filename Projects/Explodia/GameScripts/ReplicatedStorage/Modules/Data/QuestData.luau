local QuestData = {}
QuestData.Quests = {
	["quest_0000000001"] = {
		Name = "Crystal Gathering",
		Description = "Ya boi needs crystals. bluey ones.",
		QuestType = "Side Quest",
		ConsumesItems = true,
		Objectives = {
			{ObjectiveType = "Collect", Item = "Blue Crystal", Required = 6},
		},
		Rewards = {
			EXP = 500,
			Yen = 1000000,
			Fracta = 20000,
			ItemDrops = {
				["Flaming Tails"] = {Amount =  1},
			}
		}
	}	
	,
	["quest_0000000002"] = {
		Name = "Zombie Extermination",
		Description = "KILL THEM.",
		QuestType = "Normal Quest",
		Objectives = {
			{ObjectiveType = "Kill", Mob = "Zombie", Required = 1}	
		},

		Rewards = {
			EXP = 500,
			Yen = 1000000,
			Fracta = 20000,
			ItemDrops = {
				["Vision Head"] = {Amount =  1},
			}
		}
	}	
	
}









function QuestData:GetQuestID(quest)
	if not quest then return nil end
	
	for id, data in pairs(self.Quests) do
		if data.Name == quest then
			return id
		end
	end

	return nil
end

return QuestData
