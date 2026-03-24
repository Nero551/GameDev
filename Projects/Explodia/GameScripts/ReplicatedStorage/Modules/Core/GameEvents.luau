-- ReplicatedStorage.Modules.Core.GameEvents
local GameEvents = {}

GameEvents.GetData = Instance.new("BindableEvent")

GameEvents.AddBuff =  Instance.new("BindableEvent")
GameEvents.RemoveBuff = Instance.new("BindableEvent")
GameEvents.ResetBuffs = Instance.new("BindableEvent")

GameEvents.UpdateMana = Instance.new("BindableEvent")

GameEvents.ItemChanged = Instance.new("BindableEvent")

GameEvents.MobKilled = Instance.new("BindableEvent")

GameEvents.QuestCompleted = Instance.new("BindableEvent")
GameEvents.AcceptQuest = Instance.new("BindableEvent")

GameEvents.AddItem = Instance.new("BindableEvent")
GameEvents.RemoveItem = Instance.new("BindableEvent")

GameEvents.EquipItem = Instance.new("BindableEvent")
GameEvents.UnEquipItem = Instance.new("BindableEvent")

GameEvents.CurrencyChange = Instance.new("BindableEvent")

GameEvents.IncreaseEXP = Instance.new("BindableEvent")

GameEvents.GiveRewards = Instance.new("BindableEvent")


return GameEvents
