local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")

local EquipService = require(game.ServerScriptService.Services.Profile.EquipService)
local StatService = require(game.ServerScriptService.Services.Profile.StatService)
local QuestService = require(game.ServerScriptService.Services.Profile.QuestService)
local TitleService = require(game.ServerScriptService.Services.Profile.TitleService)
local DialogueService = require(game.ServerScriptService.Services.NPC.DialogueService)

local QuestData = require(game.ReplicatedStorage.Modules.Data.QuestData)

local ServerData = require(game.ServerScriptService.Modules.ServerData)
---Server Data---
Players.PlayerAdded:Connect(function(player)
	ServerData.MaxPlayers = Players.maxPlayers
	ServerData.Players = Players:GetPlayers()
	ServerData.Version = game.PlaceVersion
	local success, country = pcall(function()
		return LocalizationService:GetCountryRegionForPlayerAsync(player)
	end)
	if success then
		ServerData.Region = country	
	end
end)

Players.playerRemoving:Connect(function(player)
	ServerData.Players = Players:GetPlayers()
end)
----------------------------------------------------------------------------------------------------------------------------------

---Client Requests to Equip Item---
NetworkingService:OnServerEvent("EquipItem", function(player, itemID)
	EquipService:EquipItem(player, itemID)
end)

---Client Requests To UnEquip Item---
NetworkingService:OnServerEvent("UnequipItem", function(player, itemID)
	EquipService:UnEquipItem(player, itemID)
end)	


----------------------------------------------------------------------------------------------------------------------------------

---Client Requests To Allocate Stat Point---
NetworkingService:OnServerEvent("AllocateStatPoint", function(player:Player, StatType, amount)
	StatService:AllocateStatPoint(player, StatType, amount)
end)

---Client Requests To Reset Stat Points---
NetworkingService:OnServerEvent("ResetStatPoints", function(player)	
	StatService:ResetStats(player)
end)

----------------------------------------------------------------------------------------------------------------------------------

---Client Requests to Accept Quest---
NetworkingService:OnServerEvent("AcceptQuest", function(player, QuestName)
end)


---Client Requests to Abandon Quest---
NetworkingService:OnServerEvent("AbandonQuest", function(player, questName)
	local questID = QuestData:GetQuestID(questName)
	QuestService:AbandonQuest(player, questID)
end)


---Client Requests to Track Quest---
NetworkingService:OnServerEvent("TrackQuest", function(player:Player, questName)
	local questID = QuestData:GetQuestID(questName)
	QuestService:TrackQuest(player, questID)
end)


----------------------------------------------------------------------------------------------------------------------------------
---Client Requests to Equip Title---
NetworkingService:OnServerEvent("EquipTitle", function(player, titleID)
	TitleService:EquipTitle(player, titleID)
end)


---Client Requests to UnEquip Title---
NetworkingService:OnServerEvent("UnEquipTitle", function(player)
	TitleService:UnEquipTitle(player)
end)

----------------------------------------------------------------------------------------------------------------------------------

---Client Requests to Conitnue Dialogue---
NetworkingService:OnServerEvent("ContinueDialogue", function(player:Player)
	DialogueService:ContinueDialogue(player)
end)

---Client Selected Dialogue Option---
NetworkingService:OnServerEvent("SelectDialogueOption", function(player:Player,optionNumber)
	DialogueService:SelectDialogueOption(player, optionNumber)	
end)
