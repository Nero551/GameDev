local Players = game:GetService("Players")
local LocalizationService = game:GetService("LocalizationService")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")

local TechniqueService = require(ServerScriptService.Services.Combat.TechniqueService)
local AdminCmdsService = require(ServerScriptService.Services.Core.AdminCmdsService)
local KeybindsService = require(ServerScriptService.Services.Profile.KeybindsService)
local SettingsService = require(ServerScriptService.Services.Profile.SettingsService)
local EquipService = require(game.ServerScriptService.Services.Profile.EquipService)
local StatService = require(game.ServerScriptService.Services.Profile.StatService)
local QuestService = require(game.ServerScriptService.Services.Profile.QuestService)
local TitleService = require(game.ServerScriptService.Services.Profile.TitleService)
local DialogueService = require(game.ServerScriptService.Services.NPC.DialogueService)
local CurrencyService = require(game.ServerScriptService.Services.Profile.CurrencyService)
local DataService = require(game.ServerScriptService.Services.Core.DataService)
local LevelService = require(game.ServerScriptService.Services.Profile.LevelService)
local InventoryService = require(game.ServerScriptService.Services.Profile.InventoryService)
local BuffService = require(game.ServerScriptService.Services.Profile.BuffService)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)
local QuestData = require(game.ReplicatedStorage.Modules.Data.QuestData)
local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)

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

Players.playerRemoving:Connect(function()
	ServerData.Players = Players:GetPlayers()
end)

---Client Requests To Change Keybind---
NetworkingService:OnServerEvent("ChangeKeybind", function(player,keybind,key)
	KeybindsService:ChangeKeybind(player, keybind, key)
end)

---Admin Command---
NetworkingService:OnServerEvent("AdminCommand", function(player, msg)
	AdminCmdsService:SelectCommand(player, msg)
end)


---Client Requests to Equip Item---
NetworkingService:OnServerEvent("EquipItem", function(player, itemID)
	EquipService:EquipItem(player, itemID)
end)

---Client Requests To UnEquip Item---
NetworkingService:OnServerEvent("UnequipItem", function(player, itemID)
	EquipService:UnEquipItem(player, itemID)
end)	

---Client Requests to Equip Technique---
NetworkingService:OnServerEvent("EquipTechnique", function(player, techniqueID)
	TechniqueService:EquipTechnique(player, techniqueID)
end)

---Client Requests To UnEquip Technique---
NetworkingService:OnServerEvent("UnequipTechnique", function(player, techniqueID)
	TechniqueService:UnEquipTechnique(player, techniqueID)
end)

---Client Requests To Allocate Stat Point---
NetworkingService:OnServerEvent("AllocateStatPoint", function(player:Player, StatType, amount)
	StatService:AllocateStatPoint(player, StatType, amount)
end)

---Client Requests To Reset Stat Points---
NetworkingService:OnServerEvent("ResetStatPoints", function(player)	
	StatService:ResetStats(player)
end)

---Client Requests to Accept Quest---
NetworkingService:OnServerEvent("AcceptQuest", function()
end)

---Client Requests to Abandon Quest---
NetworkingService:OnServerEvent("AbandonQuest", function(player, questName)
	local questID = QuestData:GetQuestID(questName)
	QuestService:AbandonQuest(player, questID)
end)

---Client Requests to Track Quest---
NetworkingService:OnServerEvent("TrackQuest", function(player:Player, questID)
	QuestService:TrackQuest(player, questID)
end)

---Client Requests to Equip Title---
NetworkingService:OnServerEvent("EquipTitle", function(player, titleID)
	TitleService:EquipTitle(player, titleID)
end)

---Client Requests to UnEquip Title---
NetworkingService:OnServerEvent("UnEquipTitle", function(player)
	TitleService:UnEquipTitle(player)
end)

---Client Requests to Conitnue Dialogue---
NetworkingService:OnServerEvent("ContinueDialogue", function(player:Player)
	DialogueService:ContinueDialogue(player)
end)

---Client Selected Dialogue Option---
NetworkingService:OnServerEvent("SelectDialogueOption", function(player:Player,optionNumber)
	DialogueService:SelectDialogueOption(player, optionNumber)	
end)

local function Setup(player: Player, character)
	SettingsService:SetupSettings(player)
	TechniqueService:SetupTechniques(player)
	StatService:SetupStats(player)
	LevelService:SetupLevel(player)
	InventoryService:SetupInventory(player)
	EquipService:SetupEquipped(player)
	TitleService:SetupTitles(player)
	CurrencyService:SetupCurrencies(player)
	BuffService:SetupBuffs(player)
	QuestService:SetupQuests(player)

	VitalsService:Create(character)
	VitalsService:ModifyVital(character, "Health", "ModifyHealth", {
		["HealthChange"] = VitalsService.CharacterVitals[character].Health.MaxHealth
			- VitalsService.CharacterVitals[character].Health.CurrentHealth,
	})

	VitalsService:ModifyVital(character, "Mana", "ModifyMana", {
		["ManaChange"] = VitalsService.CharacterVitals[character].Mana.MaxMana
			- VitalsService.CharacterVitals[character].Mana.CurrentMana,
	})
end

---Load Data---
Players.PlayerAdded:Connect(function(player)
	local playerGui = player:WaitForChild("PlayerGui")
	print(DataService:Load(player))
	repeat
		task.wait()
	until #playerGui:GetDescendants() >= #StarterGui:GetDescendants()

	if player.Character then
		Setup(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		Setup(player, character)
	end)
end)

---Save Data---
Players.PlayerRemoving:Connect(function(player)
	DataService:Save(player)

	local char = player.Character

	Connections:CleanupConnections(char)
	VitalsService:Cleanup(char)
end)

---Save Data If Server Shuts Down---
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		DataService:Save(player)
	end
	task.wait(2)
end)

---AutoSave---
task.spawn(function()
	while task.wait(300) do
		for _, player in pairs(Players:GetPlayers()) do
			print("Saving For:",player)
			DataService:Save(player)
		end
	end
end)

