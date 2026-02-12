local repstor = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local remotes = repstor.Remotes
local EquipService = require(script.Parent.Parent.ServerModules.EquipService)
local DataService = require(script.Parent.Parent.ServerModules.DataService)


---Client Requests to Equip Item---
remotes.EquipItem.OnServerEvent:Connect(function(player, itemID)
	EquipService:EquipItem(player, itemID)
end)

---Client Requests To UnEquip Item---
remotes.UnequipItem.OnServerEvent:Connect(function(player, itemID)
	EquipService:UnEquipItem(player, itemID)
end)	