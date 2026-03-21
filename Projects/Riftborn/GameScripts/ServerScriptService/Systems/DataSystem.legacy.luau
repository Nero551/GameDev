local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local CurrencyService = ModuleLoader:Load("Server", "CurrencyService")
local DataService = ModuleLoader:Load("Server", "DataService")
local StatService = ModuleLoader:Load("Server", "StatService")
local LevelService = ModuleLoader:Load("Server", "LevelService")
local EquipService = ModuleLoader:Load("Server", "EquipService")
local InventoryService = ModuleLoader:Load("Server", "InventoryService")
local QuestService = ModuleLoader:Load("Server", "QuestService")
local TitleService = ModuleLoader:Load("Server", "TitleService")
local BuffService = ModuleLoader:Load("Server", "BuffService")
local CharacterVitalsService = ModuleLoader:Load("Server", "CharacterVitalsService")

local StateService = ModuleLoader:Load("Server", "StateService")
print(StateService)
local Connections = ModuleLoader:Load("Shared", "Connections")

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
	if player.Character then
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
