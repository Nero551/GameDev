local players = game:GetService("Players")
local repstor = game:GetService("ReplicatedStorage")
local remotes = repstor.Remotes

local DataService = require(script.Parent.Parent.ServerModules.DataService)
local InventoryService = require(script.Parent.Parent.ServerModules.InventoryService)


---Client Requests To Add An Item---
remotes.RequestAddItem.OnServerEvent:Connect(function(player:Player, itemID:string, amount:number)
	
	InventoryService:AddItem(itemID , amount, player)

end)

---Client Requests To Remove An Item---
remotes.RequestRemoveItem.OnServerEvent:Connect(function(player:Player, itemID:string, amount:number)
	InventoryService:RemoveItem(itemID, amount, player)
	
end)