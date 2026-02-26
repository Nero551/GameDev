local repstor = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local remotes = repstor.Remotes
local DataService = require(script.Parent.Parent.Services.DataService)
local statService = require(script.Parent.Parent.Services.StatService)
local LevelService = require(script.Parent.Parent.Services.LevelService)
local EquipService = require(script.Parent.Parent.Services.EquipService)
local InventoryService = require(script.Parent.Parent.Services.InventoryService)
local QuestService = require(script.Parent.Parent.Services.QuestService)
local TitleService = require(script.Parent.Parent.Services.TitleService)
local BuffService = require(script.Parent.Parent.Services.BuffService)
local CharacterVitalsService = require(script.Parent.Parent.Services.CharacterVitalsService)

local connections = require(game.ReplicatedStorage.Modules.Connections)

local clientReady = {}
remotes.ClientReady.OnServerEvent:Connect(function(player)
	clientReady[player] = true
end)

local function WaitForPlayerReady(player)
	-- wait until data table exists
	repeat task.wait() until DataService.PlayerDatas[player]

	-- wait until CharacterVitalsService is ready for this character
	local char = player.Character or player.CharacterAdded:Wait()
	repeat task.wait() until CharacterVitalsService.CharacterVitals[char]

	-- wait for client ready signal
	repeat task.wait() until clientReady[player]
end

local function SetupPlayer(player:Player)
	---Setup Tables And Folders---
	statService:SetupStats(player)
		
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
	local playerInventory = DataService:GetTable(player, "Inventory")
	local playerEquipped = DataService:GetTable(player, "Equipped")
	local playerQuests = DataService:GetTable(player,"Quests")
	local playerCurrencies = DataService:GetTable(player,"Currency")
	local playerTitles = DataService:GetTable(player, "Titles")
	
	WaitForPlayerReady(player)
	---Send Remotes
	remotes.UpdateEXP:FireClient(player ,playerLevel)
		
	remotes.UpdateInventory:FireClient(player, playerInventory,  playerEquipped)
	remotes.UpdateInventoryInfo:FireClient(player, playerInventory,  playerEquipped)
	
	remotes.UpdateEquippedItems:FireClient(player, playerInventory,  playerEquipped)
	
	remotes.UpdateCurrency:FireClient(player ,playerCurrencies)
	
	remotes.UpdateQuests:FireClient(player, playerQuests)
	
	remotes.UpdateTitles:FireClient(player, playerTitles)
	
end

local function SetupCharacter(player:Player, character)
	SetupPlayer(player)
	CharacterVitalsService:Create(character)
	
	SendSetupRemotes(player)
	
	CharacterVitalsService:ModifyVital(character, "Health", "ModifyHealth", {
		["HealthChange"] = CharacterVitalsService.CharacterVitals[character].Health.MaxHealth - 
			CharacterVitalsService.CharacterVitals[character].Health.CurrentHealth
		
	})
	
	CharacterVitalsService:ModifyVital(character, "Mana", "ModifyMana",{
		["ManaChange"] = CharacterVitalsService.CharacterVitals[character].Mana.MaxMana -
			CharacterVitalsService.CharacterVitals[character].Mana.CurrentMana
	})
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
	data = nil
	
	local char = player.Character
	
	connections:CleanupConnections(char)
end)

---Save Data If Server Shuts Down---
game:BindToClose(function()
	for _, player in ipairs(players:GetPlayers()) do
		local data = DataService:Save(player)
		data = nil
		local char = player.Character
		connections:CleanupConnections(char)
	end
	
	task.wait(2)
end)

---AutoSave---
task.spawn(function()
	while task.wait(300) do
		for _, player in pairs(players:GetPlayers()) do
			DataService:Save(player)
		end
	end
end)
