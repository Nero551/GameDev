local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterGui = game:GetService("StarterGui")
local CurrencyService = require(ServerScriptService.Services.CurrencyService)
local DataService = require(script.Parent.Parent.Services.DataService)
local StatService = require(script.Parent.Parent.Services.StatService)
local LevelService = require(script.Parent.Parent.Services.LevelService)
local EquipService = require(script.Parent.Parent.Services.EquipService)
local InventoryService = require(script.Parent.Parent.Services.InventoryService)
local QuestService = require(script.Parent.Parent.Services.QuestService)
local TitleService = require(script.Parent.Parent.Services.TitleService)
local BuffService = require(script.Parent.Parent.Services.BuffService)
local CharacterVitalsService = require(script.Parent.Parent.Services.CharacterVitalsService)

local Connections = require(game.ReplicatedStorage.Modules.Connections)

local function Setup(player: Player, character)
	local playerGui = player:WaitForChild("PlayerGui")

	repeat
		task.wait()
	until #playerGui:GetDescendants() >= #StarterGui:GetDescendants()

	StatService:SetupStats(player)
	LevelService:SetupLevel(player)
	InventoryService:SetupInventory(player)
	EquipService:SetupEquipped(player)
	LevelService:SetupLevel(player)
	TitleService:SetupTitles(player)
	CurrencyService:SetupCurrencies(player)

	QuestService:SyncQuestsWithQuestData(player)

	BuffService:UpdateBuffs(player)

	CharacterVitalsService:Create(character)

	CharacterVitalsService:ModifyVital(character, "Health", "ModifyHealth", {
		["HealthChange"] = CharacterVitalsService.CharacterVitals[character].Health.MaxHealth
			- CharacterVitalsService.CharacterVitals[character].Health.CurrentHealth,
	})

	CharacterVitalsService:ModifyVital(character, "Mana", "ModifyMana", {
		["ManaChange"] = CharacterVitalsService.CharacterVitals[character].Mana.MaxMana
			- CharacterVitalsService.CharacterVitals[character].Mana.CurrentMana,
	})
end

---Load Data---
Players.PlayerAdded:Connect(function(player)
	local playerData = DataService:Load(player)
	if player.character then
		Setup(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		Setup(player, character)
	end)
	print(playerData)
end)

---Save Data---
Players.PlayerRemoving:Connect(function(player)
	DataService:Save(player)

	local char = player.Character

	Connections:CleanupConnections(char)
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
			DataService:Save(player)
		end
	end
end)
