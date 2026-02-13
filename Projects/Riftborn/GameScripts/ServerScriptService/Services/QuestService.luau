local repstor = game:GetService("ReplicatedStorage")
local questDataBase = require(repstor.Modules.Data.QuestData)
local GameEvents = require(repstor.Modules.GameEvents)
local InventoryService = require(script.Parent.InventoryService)
local itemDataBase = require(repstor.Modules.Data.ItemDataBase)
local DataService = require(script.Parent.DataService)

local QuestService = {}

-----------------------------------------------------------------------------------------------------------------------------
function QuestService:AcceptQuest(player:Player, questID)
	local playerQuests = DataService:GetTable(player, "Quests")
	if playerQuests.ActiveQuests[questID] then  return end
	local  questData =  questDataBase.Quests[questID]
	if not questData then return end
	
	
	playerQuests.ActiveQuests[questID] = {
		Progress = {},
		Name = questData.Name,
		Completed = false,	
		QuestType = questData.QuestType,
		QuestDescription = questData.Description,
		Rewards = questData.Rewards
	}
	for objectiveNumber, objective in ipairs(questData.Objectives) do
		
		if objective.ObjectiveType == "Collect" then
			playerQuests.ActiveQuests[questID].Progress[objectiveNumber] = {
				Item = objective.Item,
				CurrentProgress = 0,
				Required = objective.Required,
				ObjectiveType = objective.ObjectiveType,
			}
		end
		if objective.ObjectiveType == "Kill" then
			playerQuests.ActiveQuests[questID].Progress[objectiveNumber] = {
				Mob = objective.Mob,
				CurrentProgress = 0,
				Required = objective.Required,
				ObjectiveType = objective.ObjectiveType,
			}
		end
		
	end	
	
	QuestService:ProgressQuest(player)
	
	if playerQuests.TrackedQuest == nil then
		QuestService:TrackQuest(player, questID)
	end
	
repstor.Remotes.PopUp:FireClient(player,{
	["QuestName"] = questData.Name
})
repstor.Remotes.UpdateQuests:FireClient(player, playerQuests)
end


-----------------------------------------------------------------------------------------------------------------------------
function QuestService:AbandonQuest(player:Player, questID)
	local playerQuests = DataService:GetTable(player, "Quests")
	if not playerQuests then  return end
	local questName
	if playerQuests.ActiveQuests[questID] then
	questName = playerQuests.ActiveQuests[questID].Name
	playerQuests.ActiveQuests[questID] = nil
	end
	if playerQuests.TrackedQuest == questID  then
		playerQuests.TrackedQuest = nil
	end
	
	
	repstor.Remotes.PopUp:FireClient(player,{
		["QuestName"] = questName,
		["QuestAbandonded"] = true
	})
	repstor.Remotes.UpdateQuests:FireClient(player, playerQuests)
end


-----------------------------------------------------------------------------------------------------------------------------
function QuestService:TrackQuest(player:Player, questID)
	local playerQuests = DataService:GetTable(player, "Quests")
	if playerQuests.ActiveQuests[questID] then
		if  playerQuests.TrackedQuest == questID then 
			playerQuests.TrackedQuest = nil
		else
			playerQuests.TrackedQuest = questID
		end

	elseif  playerQuests.CompletedQuests[questID] then
		playerQuests.TrackedQuest = nil
	end
	
	repstor.Remotes.UpdateQuests:FireClient(player , playerQuests)
end


-----------------------------------------------------------------------------------------------------------------------------
function QuestService:ProgressQuest(player:Player, mobKilled)
	local playerQuests = DataService:GetTable(player, "Quests")
	local playerInventory = DataService:GetTable(player ,"Inventory")
	local quests = playerQuests.ActiveQuests
	if quests then
		for  questID,quest in pairs(quests) do
			for objectiveNumber, objective in pairs(quest.Progress) do

				---If Collect Quest---
				if objective.ObjectiveType == "Collect" then
					local itemdata,itemID = itemDataBase:GetItemData(objective.Item)
					if playerInventory[itemID] then
						objective.CurrentProgress = math.min(playerInventory[itemID].Amount, objective.Required)
					else
						objective.CurrentProgress = 0
					end
				end	

				---If Kill Quest---
				if objective.ObjectiveType == "Kill" then
					if mobKilled then
						if mobKilled == objective.Mob then
							objective.CurrentProgress = math.min(objective.CurrentProgress + 1,objective.Required)
						end
					end
				end	
			end
		end
	end
	repstor.Remotes.UpdateQuests:FireClient(player, playerQuests)
end


-----------------------------------------------------------------------------------------------------------------------------
function QuestService:CheckQuestCompletion(player: Player, questID)
	local playerQuests = DataService:GetTable(player, "Quests")
	local quest = playerQuests.ActiveQuests[questID]
	if not quest then return end
	-- Check Items
	for objectiveNumber, objective in pairs(quest.Progress) do
		if objective.CurrentProgress < objective.Required then
			repstor.Remotes.UpdateQuests:FireClient(player, playerQuests)
			return false
		end
	end
	
	quest.Completed = true
	QuestService:CompleteQuest(player, questID)
	return true
end


-----------------------------------------------------------------------------------------------------------------------------
function QuestService:CompleteQuest(player:Player, questID)
	local playerQuests = DataService:GetTable(player, "Quests")
	local playerInventory = DataService:GetTable(player ,"Inventory")
	local playerEquipped = DataService:GetTable(player, "Equipped")
	
	local quest = playerQuests.ActiveQuests[questID]
	if not quest then  return end
	local questData = questDataBase.Quests[questID]
	if  not questData then return end
	
	if quest.Completed == true then
		for objectiveNumber,objective in pairs(quest.Progress) do
			if objective.Item then
				local itemData,itemID = itemDataBase:GetItemData(objective.Item)
				if playerEquipped[itemID] then
					return
				end
				if questData.ConsumesItems then
					GameEvents.RemoveItem:Fire(itemID, objective.Required,player)
				end
			end	
		end
		
		playerQuests.TrackedQuest = nil
		playerQuests.CompletedQuests[questID] = questData
		playerQuests.ActiveQuests[questID] = nil
		GameEvents.GiveRewards:Fire(player, questData.Rewards, true)
		repstor.Remotes.PopUp:FireClient(player,{
			["QuestName"] = questData.Name,
			["QuestCompleted"] = true
		})		repstor.Remotes.UpdateQuests:FireClient(player, playerQuests)
		return true
	else
		repstor.Remotes.UpdateQuests:FireClient(player, playerQuests)
		return false
	end	
end


-----------------------------------------------------------------------------------------------------------------------------
function QuestService:SyncQuestsWithQuestData(player:Player)
	local playerQuests = DataService:GetTable(player, "Quests")
	for questID, quest in pairs(playerQuests.ActiveQuests) do
		local questData = questDataBase.Quests[questID]
		quest.Name = questData.Name
		quest.QuestDescription = questData.Description
		quest.QuestType = questData.QuestType
		quest.Rewards = questData.Rewards
		for objectiveIndex, objective in pairs(quest.Progress) do
			objective.Required = questData.Objectives[objectiveIndex].Required
		end
	end
end


-----------------------------------------------------------------------------------------------------------------------------
return QuestService
