local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
local repstor = game:GetService("ReplicatedStorage")
local questDataBase = require(repstor.Modules.Data.QuestData)
local GameEvents = require(repstor.Modules.GameEvents)
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
	
NetworkingService:FireToClient(player, "PopUp", {
	["QuestName"] = questData.Name
})
NetworkingService:FireToClient(player, "UpdateQuests", playerQuests)
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
	
	
	NetworkingService:FireToClient(player, "PopUp", {
		["QuestName"] = questName,
		["QuestAbandonded"] = true
	})
	NetworkingService:FireToClient(player, "UpdateQuests", playerQuests)
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
	
	NetworkingService:FireToClient(player , "UpdateQuests", playerQuests)
end


-----------------------------------------------------------------------------------------------------------------------------
function QuestService:ProgressQuest(player:Player, mobKilled)
	local playerQuests = DataService:GetTable(player, "Quests")
	local quests = playerQuests.ActiveQuests
	if quests then
		for  questID,quest in pairs(quests) do
			for objectiveNumber, objective in pairs(quest.Progress) do

				QuestService[objective.ObjectiveType.."Type"](QuestService, objective,
				 {
					["Player"] = player,
					["MobKilled"] = mobKilled,
				})
			end
		end
	end
	NetworkingService:FireToClient(player, "UpdateQuests", playerQuests)
end

-- * Add custom  functions for each objective Type.
function QuestService:CollectType(objective, argumentData)
	local player = argumentData.Player

	local playerInventory = DataService:GetTable(player ,"Inventory")
	if objective.ObjectiveType == "Collect" then
		local _,itemID = itemDataBase:GetItemData(objective.Item)
		if playerInventory[itemID] then
			objective.CurrentProgress = math.min(playerInventory[itemID].Amount, objective.Required)
		else
			objective.CurrentProgress = 0
		end
	end	
end

function QuestService:KillType(objective, argumentData)
	local mobKilled = argumentData.MobKilled
	if mobKilled then
		if mobKilled == objective.Mob then
			objective.CurrentProgress = math.min(objective.CurrentProgress + 1,objective.Required)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------
function QuestService:CheckQuestCompletion(player: Player, questID)
	local playerQuests = DataService:GetTable(player, "Quests")
	local quest = playerQuests.ActiveQuests[questID]
	if not quest then return end
	
	for objectiveNumber, objective in pairs(quest.Progress) do
		if objective.CurrentProgress < objective.Required then
			NetworkingService:FireToClient(player, "UpdateQuests", playerQuests)
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
	local playerEquipped = DataService:GetTable(player, "Equipped")
	
	local quest = playerQuests.ActiveQuests[questID]
	if not quest then  return end
	local questData = questDataBase.Quests[questID]
	if  not questData then return end
	
	if quest.Completed == true then
		for objectiveNumber,objective in pairs(quest.Progress) do
			if objective.Item then
				local _,itemID = itemDataBase:GetItemData(objective.Item)
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
		NetworkingService:FireToClient(player, "PopUp", {
			["QuestName"] = questData.Name,
			["QuestCompleted"] = true
		})		
		NetworkingService:FireToClient(player, "UpdateQuests", playerQuests)
		return true
	else
		NetworkingService:FireToClient(player, "UpdateQuests", playerQuests)
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
