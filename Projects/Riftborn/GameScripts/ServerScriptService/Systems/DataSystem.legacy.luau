local repstor = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local remotes = repstor.Remotes
local DataService = require(script.Parent.Parent.Services.DataService)
local statService = require(script.Parent.Parent.Services.StatService)
local ManaService = require(script.Parent.Parent.Services.ManaService)
local LevelService = require(script.Parent.Parent.Services.LevelService)
local EquipService = require(script.Parent.Parent.Services.EquipService)
local InventoryService = require(script.Parent.Parent.Services.InventoryService)
local QuestService = require(script.Parent.Parent.Services.QuestService)
local TitleService = require(script.Parent.Parent.Services.TitleService)
local BuffService = require(script.Parent.Parent.Services.BuffService)


local clientReady = {}
remotes.ClientReady.OnServerEvent:Connect(function(player)
	clientReady[player] = true
end)


local function SetupPlayer(player:Player)
	---Setup Tables And Folders---
	statService:SetupStats(player)
	
	ManaService:SetupMana(player)
	
	InventoryService:SyncInventoryWithDatabase(player)
	
	EquipService:LoadEquippedItems(player)
	
	LevelService:SetupLevel(player)
	LevelService:IncreaseEXP(player, 0)
	
	QuestService:SyncQuestsWithQuestData(player)
	
	TitleService:SetupTitle(player)
	TitleService:SyncTitlesWithTitleData(player)
	
	BuffService:UpdateBuffs(player)
end

local function SendSetupRemotes(player:Player)
	local playerLevel = DataService:GetTable(player, "Level")
	local playerStats = DataService:GetTable(player, "Stats")
	local playerInventory = DataService:GetTable(player, "Inventory")
	local playerEquipped = DataService:GetTable(player, "Equipped")
	local playerQuests = DataService:GetTable(player,"Quests")
	local playerCurrencies = DataService:GetTable(player,"Currency")
	local playerTitles = DataService:GetTable(player, "Titles")
	
	while not clientReady[player] do
		task.wait()
	end
	---Send Remotes
	remotes.UpdateEXP:FireClient(player ,playerLevel)
	
	remotes.UpdateStats:FireClient(player , playerStats, playerInventory, playerEquipped)
	
	remotes.UpdateInventory:FireClient(player, playerInventory,  playerEquipped)
	remotes.UpdateInventoryInfo:FireClient(player, playerInventory,  playerEquipped)
	
	remotes.UpdateEquippedItems:FireClient(player, playerInventory,  playerEquipped)
	
	remotes.UpdateCurrency:FireClient(player ,playerCurrencies)
	
	remotes.UpdateQuests:FireClient(player, playerQuests)
	
	remotes.UpdateTitles:FireClient(player, playerTitles)
	
end

local function SetupCharacter(player:Player, character)
	wait()
	SetupPlayer(player)
	SendSetupRemotes(player)
	
	local humanoid:Humanoid = character:WaitForChild("Humanoid")
	local manaFolder =  player:WaitForChild("PlayerMana")
	local playerMana = DataService:GetTable(player,"Mana")
	playerMana.CurrentMana = playerMana.MaxMana
	manaFolder.MaxMana.Value = playerMana.MaxMana
	manaFolder.CurrentMana.Value = playerMana.CurrentMana
	humanoid.Health = humanoid.MaxHealth
	
end

---Load Data---
players.PlayerAdded:Connect(function(player)
	
	local playerData = DataService:Load(player)	
	
	SetupPlayer(player)	
	
	---SetupCharacter---
	if player.Character then
		print(playerData)
		SetupCharacter(player, player.Character)
	end
	
	player.CharacterAdded:Connect(function(character)		
		print(playerData)
		
		SetupCharacter(player, character)
	end)
end)


---Save Data---
players.PlayerRemoving:Connect(function(player)

	local data = DataService:Save(player)
	clientReady[player] = nil
	DataService.PlayerDatas[player] = nil
	
end)

---Save Data If Server Shuts Down---
game:BindToClose(function()
	for _, player in ipairs(players:GetPlayers()) do
		local data = DataService:Save(player)
		DataService.PlayerData[player] = nil
	end
	task.wait(2)
end)

---AutoSave---
spawn(function()
	while true do
		for _, player in pairs(players:GetPlayers()) do
			DataService:Save(player)
		end
		task.wait(300) -- 5 min
	end
end)



