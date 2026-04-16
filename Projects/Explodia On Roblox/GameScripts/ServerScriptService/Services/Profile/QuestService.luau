local ServerScriptService = game:GetService("ServerScriptService")
local RewardsService = require(ServerScriptService.Services.World.RewardsService)
local InventoryService = require(script.Parent.InventoryService)
local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local QuestData = require(game.ReplicatedStorage.Modules.Data.QuestData)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local DataService = require(game.ServerScriptService.Services.Core.DataService)

local QuestService = {}

local function SetUpdates(player: Player)
	local playerQuests = DataService:GetTable(player, "Quests")
	local folder = player:FindFirstChild("Quests")
	folder:FindFirstChild("TrackedQuest"):SetAttribute("ID", (playerQuests.TrackedQuest or ""))
	for questID, activeQuest in pairs(playerQuests.ActiveQuests) do
		local questFolder = folder:FindFirstChild("ActiveQuests"):FindFirstChild(questID)
		if not questFolder then
			questFolder = Instance.new("Folder")
			questFolder.Name = questID
			questFolder.Parent = folder:FindFirstChild("ActiveQuests")
		end
		questFolder:SetAttribute("Completed", activeQuest.Completed)
		for index, objective in ipairs(activeQuest.Progress) do
			local value = questFolder:FindFirstChild(index)
			if not value then
				value = Instance.new("StringValue")
				value.Name = index
				value.Parent = questFolder
			end
			for infoName, v in pairs(objective) do
				value:SetAttribute(infoName, v)
			end
		end
	end

	for questID, completedQuest in pairs(playerQuests.CompletedQuests) do
		local questFolder = folder:FindFirstChild("CompletedQuests"):FindFirstChild(questID)
		if not questFolder then
			questFolder = Instance.new("Folder")
			questFolder.Name = questID
			questFolder.Parent = folder:FindFirstChild("CompletedQuests")
		end

		if folder:FindFirstChild("ActiveQuests"):FindFirstChild(questID) and not playerQuests.ActiveQuests[questID] then
			folder:FindFirstChild("ActiveQuests"):FindFirstChild(questID):Destroy()
		end
		questFolder:SetAttribute("Completed", completedQuest.Completed)
		for index, objective in ipairs(completedQuest.Progress) do
			local value = questFolder:FindFirstChild(index)
			if not value then
				value = Instance.new("StringValue")
				value.Name = index
				value.Parent = questFolder
			end
			for infoName, v in pairs(objective) do
				value:SetAttribute(infoName, v)
			end
		end
	end
end

function QuestService:SetupQuests(player: Player)
	local folder = player:FindFirstChild("Quests")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Quests"
		folder.Parent = player

		local activeQuestsFolder = Instance.new("Folder")
		activeQuestsFolder.Name = "ActiveQuests"
		activeQuestsFolder.Parent = folder

		local completedQuestsFolder = Instance.new("Folder")
		completedQuestsFolder.Name = "CompletedQuests"
		completedQuestsFolder.Parent = folder

		local trackedQuest = Instance.new("StringValue")
		trackedQuest.Name = "TrackedQuest"
		trackedQuest.Parent = folder
	end

	QuestService:SyncQuestsWithQuestData(player)
	SetUpdates(player)
end

-----------------------------------------------------------------------------------------------------------------------------
function QuestService:AcceptQuest(player: Player, questID)
	local playerQuests = DataService:GetTable(player, "Quests")
	if playerQuests.ActiveQuests[questID] then
		return
	end
	local questData = QuestData.Quests[questID]
	if not questData then
		return
	end

	playerQuests.ActiveQuests[questID] = {
		Progress = {},
		Completed = false,
	}
	for objectiveNumber, objective in ipairs(questData.Objectives) do
		if objective.ObjectiveType == "Collect" then
			playerQuests.ActiveQuests[questID].Progress[objectiveNumber] = {
				Item = objective.Item,
				Current = 0,
				Required = objective.Required,
				ObjectiveType = objective.ObjectiveType,
			}
		end
		if objective.ObjectiveType == "Kill" then
			playerQuests.ActiveQuests[questID].Progress[objectiveNumber] = {
				Mob = objective.Mob,
				Current = 0,
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
		["QuestName"] = questData.Name,
	})

	SetUpdates(player)
end

-----------------------------------------------------------------------------------------------------------------------------
function QuestService:AbandonQuest(player: Player, questID)
	local playerQuests = DataService:GetTable(player, "Quests")
	if not playerQuests then
		return
	end
	local questName
	if playerQuests.ActiveQuests[questID] then
		local questData = QuestData.Quests[questID]
		if not questData then
			return
		end
		questName = questData.Name
		playerQuests.ActiveQuests[questID] = nil
	end
	if playerQuests.TrackedQuest == questID then
		playerQuests.TrackedQuest = nil
	end

	NetworkingService:FireToClient(player, "PopUp", {
		["QuestName"] = questName,
		["QuestAbandonded"] = true,
	})
	SetUpdates(player)
end

-----------------------------------------------------------------------------------------------------------------------------
function QuestService:TrackQuest(player: Player, questID)
	local playerQuests = DataService:GetTable(player, "Quests")
	if playerQuests.ActiveQuests[questID] then
		if playerQuests.TrackedQuest == questID then
			playerQuests.TrackedQuest = nil
		else
			playerQuests.TrackedQuest = questID
		end
	elseif playerQuests.CompletedQuests[questID] then
		playerQuests.TrackedQuest = nil
	end

	SetUpdates(player)
end

-----------------------------------------------------------------------------------------------------------------------------
function QuestService:ProgressQuest(player: Player, mobKilled)
	local playerQuests = DataService:GetTable(player, "Quests")
	local quests = playerQuests.ActiveQuests
	if quests then
		for questID, quest in pairs(quests) do
			for _, objective in pairs(quest.Progress) do
				QuestService[objective.ObjectiveType .. "Type"](QuestService, objective, {
					["Player"] = player,
					["MobKilled"] = mobKilled,
				})
			end
		end
	end
	SetUpdates(player)
end

-- * Add custom  functions for each objective Type.
function QuestService:CollectType(objective, argumentData)
	local player = argumentData.Player

	local playerInventory = DataService:GetTable(player, "Inventory")
	if objective.ObjectiveType == "Collect" then
		local _, itemID = ItemDataBase:GetItemData(objective.Item)
		if playerInventory[itemID] then
			objective.Current = math.min(playerInventory[itemID].Amount, objective.Required)
		else
			objective.Current = 0
		end
	end
end

function QuestService:KillType(objective, argumentData)
	local mobKilled = argumentData.MobKilled
	if mobKilled then
		if mobKilled == objective.Mob then
			objective.Current = math.min(objective.Current + 1, objective.Required)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------
function QuestService:CheckQuestCompletion(player: Player, questID)
	local playerQuests = DataService:GetTable(player, "Quests")
	local quest = playerQuests.ActiveQuests[questID]
	if not quest then
		return
	end

	for _, objective in pairs(quest.Progress) do
		if objective.Current < objective.Required then
			SetUpdates(player)
			return false
		end
	end

	quest.Completed = true
	QuestService:CompleteQuest(player, questID)
	return true
end

-----------------------------------------------------------------------------------------------------------------------------
function QuestService:CompleteQuest(player: Player, questID)
	local playerQuests = DataService:GetTable(player, "Quests")
	local playerEquipped = DataService:GetTable(player, "Equipped")

	local quest = playerQuests.ActiveQuests[questID]
	if not quest then
		return
	end
	local questData = QuestData.Quests[questID]
	if not questData then
		return
	end

	if quest.Completed == true then
		for _, objective in pairs(quest.Progress) do
			if objective.Item then
				local _, itemID = ItemDataBase:GetItemData(objective.Item)
				if playerEquipped[itemID] then
					return
				end
				if questData.ConsumesItems then
					InventoryService:RemoveItem(itemID, objective.Required, player)
				end
			end
		end

		playerQuests.TrackedQuest = nil
		playerQuests.CompletedQuests[questID] = playerQuests.ActiveQuests[questID]
		playerQuests.ActiveQuests[questID] = nil
		RewardsService:GiveRewards(player, questData.Rewards, true)
		NetworkingService:FireToClient(player, "PopUp", {
			["QuestName"] = questData.Name,
			["QuestCompleted"] = true,
		})
	end
	SetUpdates(player)
	return
end

-----------------------------------------------------------------------------------------------------------------------------
function QuestService:SyncQuestsWithQuestData(player: Player)
	local playerQuests = DataService:GetTable(player, "Quests")
	for questID, quest in pairs(playerQuests.ActiveQuests) do
		local questData = QuestData.Quests[questID]
		for objectiveIndex, objective in pairs(quest.Progress) do
			objective.Required = questData.Objectives[objectiveIndex].Required
		end
	end
	SetUpdates(player)
end

-----------------------------------------------------------------------------------------------------------------------------
return QuestService