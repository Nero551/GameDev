local players = game:GetService("Players")
local repstor = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")

local remotes = repstor.Remotes
local InventoryService = require(script.Parent.Parent.Services.InventoryService)
local EquipService = require(script.Parent.Parent.Services.EquipService)
local StatService = require(script.Parent.Parent.Services.StatService)
local QuestService = require(script.Parent.Parent.Services.QuestService)
local TitleService = require(script.Parent.Parent.Services.TitleService)
local DialogueService = require(script.Parent.Parent.Services.DialogueService)

local QuestData = require(repstor.Modules.Data.QuestData)

local ServerData = require(script.Parent.Parent.Modules.ServerData)


players.PlayerAdded:Connect(function(player)
	ServerData.MaxPlayers = players.maxPlayers
	ServerData.Players = players:GetPlayers()
	ServerData.Version = game.PlaceVersion
	local success, country = pcall(function()
		return LocalizationService:GetCountryRegionForPlayerAsync(player)
	end)
	if success then
		ServerData.Region = country
	end
end)

players.playerRemoving:Connect(function(player)
	ServerData.Players = players:GetPlayers()
end)

---Client Requests To Add An Item---
remotes.RequestAddItem.OnServerEvent:Connect(function(player:Player, itemID:string, amount:number)

	InventoryService:AddItem(itemID , amount, player)

end)

---Client Requests To Remove An Item---
remotes.RequestRemoveItem.OnServerEvent:Connect(function(player:Player, itemID:string, amount:number)
	InventoryService:RemoveItem(itemID, amount, player)

end)

----------------------------------------------------------------------------------------------------------------------------------

---Client Requests to Equip Item---
remotes.EquipItem.OnServerEvent:Connect(function(player, itemID)
	EquipService:EquipItem(player, itemID)
end)

---Client Requests To UnEquip Item---
remotes.UnequipItem.OnServerEvent:Connect(function(player, itemID)
	EquipService:UnEquipItem(player, itemID)
end)	


----------------------------------------------------------------------------------------------------------------------------------

---Client Requests To Allocate Stat Point---
remotes.AllocateStatPoint.OnServerEvent:Connect(function(player:Player, StatType, amount)

	StatService:AllocateStatPoint(player, StatType, amount)
end)

---Client Requests To Reset Stat Points---
remotes.ResetStatPoints.OnServerEvent:Connect(function(player)	
	StatService:ResetStats(player)
end)

----------------------------------------------------------------------------------------------------------------------------------

---Client Requests to Accept Quest---
remotes.AcceptQuest.OnServerEvent:Connect(function(player, QuestName)
end)


---Client Requests to Abandon Quest---
remotes.AbandonQuest.OnServerEvent:Connect(function(player, questName)
	local questID = QuestData:GetQuestID(questName)
	QuestService:AbandonQuest(player, questID)
end)


---Client Requests to Track Quest---
remotes.TrackQuest.OnServerEvent:Connect(function(player:Player, questName)
	local questID = QuestData:GetQuestID(questName)
	QuestService:TrackQuest(player, questID)
end)


----------------------------------------------------------------------------------------------------------------------------------

---Client Requests to Equip Title---
remotes.EquipTitle.OnServerEvent:Connect(function(player, titleID)
	TitleService:EquipTitle(player, titleID)
end)


---Client Requests to UnEquip Title---
remotes.UnEquipTitle.OnServerEvent:Connect(function(player)
	TitleService:UnEquipTitle(player)
end)

----------------------------------------------------------------------------------------------------------------------------------

---Client Requests to Conitnue Dialogue---
remotes.ContinueDialogue.OnServerEvent:Connect(function(player:Player)
	DialogueService:ContinueDialogue(player)
end)

---Client Selected Dialogue Option---
remotes.SelectDialogueOption.OnServerEvent:Connect(function(player:Player,optionNumber)
	DialogueService:SelectDialogueOption(player, optionNumber)	
end)