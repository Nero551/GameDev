local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
local repstor = game:GetService("ReplicatedStorage")
local modules = repstor.Modules
local GameEvents = require(modules.GameEvents)
local itemDataBase = require(modules.Data.ItemDataBase)

local DataService = require(script.Parent.Parent.Services.DataService)

local InventoryService = {}

------Add An Item------
function InventoryService:AddItem(itemID:string, amount:number, player:Player)
	local inventory = DataService:GetTable(player, "Inventory")
	local EquippedItems = DataService:GetTable(player, "Equipped")
	if not inventory then return end
	
	amount = amount or 1
	local itemData = itemDataBase:GetItemData(itemID)
	
	-- Validate item
	if not itemData then
		warn("Invalid item:", itemID)
		return false
	end	
	
	-- Create entry if missing
	if not inventory[itemID] then
		inventory[itemID] = {Name = itemData.Name ,Amount = 0 , Type = itemData.Type , Rarity = itemData.Rarity,
        Icon = itemData.Icon, Description = itemData.Description}
	end
	

	
	-- Handle stacking
	if itemData.Stackable then
		local maxStack = itemData.MaxStack or math.huge
		inventory[itemID].Amount =
			math.clamp(
				inventory[itemID].Amount + amount,
				0,
				maxStack
			)
		NetworkingService:FireToClient(player, "PopUp", {
			["ItemName"] = itemData.Name,
			["ItemRarity"] = itemData.Rarity,
			["ItemAmount"] = math.clamp(amount, 0, maxStack),
			
		})
	else
		inventory[itemID].Amount = 1
		NetworkingService:FireToClient(player, "PopUp", {
			["ItemName"] = itemData.Name,
			["ItemRarity"] = itemData.Rarity,
			["ItemAmount"] = 1,

		})
	end
	NetworkingService:FireToClient(player, "UpdateInventory", inventory,  EquippedItems)
	NetworkingService:FireToClient(player, "UpdateInventoryInfo", inventory,  EquippedItems)
	GameEvents.ItemChanged:Fire(player)
	
	return true
end

------Remove An Item------
function InventoryService:RemoveItem(itemID:string , amount:number, player)
	local inventory = DataService:GetTable(player, "Inventory")
	local EquippedItems = DataService:GetTable(player, "Equipped")
	
	if not inventory then return end
	
	amount = amount or 1
	-- Check if item exists in inventory
	if not inventory[itemID] then
		warn("Item not found in inventory:", itemID)
		return false
	end
	
	inventory[itemID].Amount -= amount
	if inventory[itemID].Amount <= 0 then
		inventory[itemID] = nil
	end	
		
	NetworkingService:FireToClient(player, "UpdateInventory", inventory,  EquippedItems)
	NetworkingService:FireToClient(player, "UpdateInventoryInfo", inventory,  EquippedItems)
	GameEvents.ItemChanged:Fire(player)
	
	return true	
end

---Sync Item Data Changes With Inventory---
function InventoryService:SyncInventoryWithDatabase(player)
	local EquippedItems = DataService:GetTable(player, "Equipped")
	local inventory = DataService:GetTable(player, "Inventory")
	if not inventory then return end
	
	for itemID,itemInfo in  pairs(inventory) do
		local itemData = itemDataBase:GetItemData(itemID)
		itemInfo.Description = itemData.Description
		itemInfo.Icon = itemData.Icon
		itemInfo.Rarity = itemData.Rarity
		itemInfo.Type = itemData.Type
		itemInfo.Name = itemData.Name
	end
	NetworkingService:FireToClient(player, "UpdateInventory", inventory, EquippedItems)
	NetworkingService:FireToClient(player, "UpdateInventoryInfo", inventory, EquippedItems)
end

return InventoryService
                                        
