local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local CurrencyService = require(game.ServerScriptService.Services.Profile.CurrencyService)
local DataService = require(game.ServerScriptService.Services.Core.DataService)
local StatService = require(game.ServerScriptService.Services.Profile.StatService)
local LevelService = require(game.ServerScriptService.Services.Profile.LevelService)
local EquipService = require(game.ServerScriptService.Services.Profile.EquipService)
local InventoryService = require(game.ServerScriptService.Services.Profile.InventoryService)
local QuestService = require(game.ServerScriptService.Services.Profile.QuestService)
local TitleService = require(game.ServerScriptService.Services.Profile.TitleService)
local BuffService = require(game.ServerScriptService.Services.Profile.BuffService)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)

local function Setup(player: Player, character)
	StatService:SetupStats(player)
	LevelService:SetupLevel(player)
	InventoryService:SetupInventory(player)
	EquipService:SetupEquipped(player)
	TitleService:SetupTitles(player)
	CurrencyService:SetupCurrencies(player)
	BuffService:UpdateBuffs(player)
	QuestService:SetupQuests(player)
	QuestService:SyncQuestsWithQuestData(player)

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
