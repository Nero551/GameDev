local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.Modules
local GameEvents = require(modules.GameEvents)
local ItemDataBase = require(modules.Data.ItemDataBase)

local DataService = require(script.Parent.Parent.Services.DataService)

local InventoryService = {}

function InventoryService:SetupInventory(player)
	local Folder = player:FindFirstChild("Inventory")
	if not Folder then
		Folder = Instance.new("Folder")
		Folder.Name = "Inventory"
		Folder.Parent = player
	end

	local Inventory = DataService:GetTable(player, "Inventory")
	for itemID,itemInfo in pairs(Inventory) do
		local itemData = ItemDataBase:GetItemData(itemID)
		local value = Folder:FindFirstChild(itemID)
		if not value then
			value = Instance.new("StringValue")
			value.Name = itemID
			value.Parent = Folder
		end
		value:SetAttribute("Name", itemData.Name)
		value:SetAttribute("Amount", itemInfo.Amount)
	end
end

------Add An Item------
function InventoryService:AddItem(itemID:string, amount:number, player:Player)
	local inventory = DataService:GetTable(player, "Inventory")
	if not inventory then return end
	
	amount = amount or 1
	local itemData = ItemDataBase:GetItemData(itemID)
	
	-- Validate item
	if not itemData then
		warn("Invalid item:", itemID)
		return false
	end	
	
	-- Create entry if missing
	if not inventory[itemID] then
		inventory[itemID] = {Amount = 0}
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

	local folder = player:FindFirstChild("Inventory")
	local value = folder:FindFirstChild(itemID)
	if not value then
		 value = Instance.new("StringValue")
		value.Name = itemID
		value.Parent = player:FindFirstChild("Inventory")
	end
	value:SetAttribute("Name", itemData.Name)
	value:SetAttribute("Amount", inventory[itemID].Amount)

	GameEvents.ItemChanged:Fire(player)
	return true
end

------Remove An Item------
function InventoryService:RemoveItem(itemID:string , amount:number, player)
	local inventory = DataService:GetTable(player, "Inventory")
	local itemData = ItemDataBase:GetItemData(itemID)
	
	if not inventory then return end
	
	amount = amount or 1
	-- Check if item exists in inventory
	local folder = player:FindFirstChild("Inventory")
	local value = folder:FindFirstChild(itemID)

	if not inventory[itemID] then
		warn("Item not found in inventory:", itemID)
		if value then
			value:Destroy()
		end
		return false
	end
	
	inventory[itemID].Amount -= amount
	if inventory[itemID].Amount <= 0 then
		inventory[itemID] = nil
		if value then
			value:Destroy()
		end
	else
		if value then
			value:SetAttribute("Name", itemData.Name)
			value:SetAttribute("Amount", inventory[itemID].Amount)
		end	
	end	
		
	GameEvents.ItemChanged:Fire(player)
	return true	
end
return InventoryService
                                        
