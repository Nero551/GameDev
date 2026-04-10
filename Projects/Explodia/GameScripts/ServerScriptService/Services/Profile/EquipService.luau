local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local VitalsService = require(ServerScriptService.Services.Combat.VitalsService)
local BuffService = require(script.Parent.BuffService)
local ToolLoader = require(game.ServerScriptService.Modules.Utilities.ToolLoader)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local DataService = require(game.ServerScriptService.Services.Core.DataService)

local EquipService = {}

function EquipService:SetupEquipped(player)
	local char = player.Character or player.CharacterAdded:Wait()
	local folder = player:FindFirstChild("Equipped")
	local inventory = DataService:GetTable(player, "Inventory")
	local EquippedItems = DataService:GetTable(player, "Equipped")

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Equipped"
		folder.Parent = player
	end

	for catagory, tbl in pairs(EquippedItems) do
		local catagoryFolder = folder:FindFirstChild(catagory)
		if not catagoryFolder then
			catagoryFolder = Instance.new("Folder")
			catagoryFolder.Name = catagory
			catagoryFolder.Parent = folder
		end
		for type, itemID in pairs(tbl) do
			local val = catagoryFolder:FindFirstChild(type)
			if not val then
				val = Instance.new("StringValue")
				val.Name = type
				val:SetAttribute("ItemID", itemID)
				val.Parent = catagoryFolder
			end

			---Must own the Item---
			if not inventory[itemID] then
				warn(itemID .. " Not Found In Inventory")
				continue
			end

			---If  A Weapon---
			local itemData = ItemDataBase:GetItemData(itemID)
			if itemData then
				if string.find(itemID, "weapon") then
					---Cloning Equipped Tools---
					local tool = player.Backpack:FindFirstChild(itemData.Name)
					if not tool then
						tool = ServerStorage.Tools[itemData.Type]:FindFirstChild(itemData.Name):Clone()
						tool.Parent = player.Backpack
						ToolLoader(tool)
					end
				elseif string.find(itemID, "armor") then
					---Cloning Equipped Armor---
					local armor = char:FindFirstChild(itemData.Name)
					if not armor then
						armor = ServerStorage.Armors[itemData.Type]:FindFirstChild(itemData.Name):Clone()
						armor.Parent = char
					end
				end
				if itemData.Buffs then
					BuffService:AddBuff(player, itemData, itemID)
				end
			end
		end
	end
end

function EquipService:EquipItem(player: Player, itemID)
	local char = player.Character or player.CharacterAdded:Wait()
	local inventory = DataService:GetTable(player, "Inventory")
	local equippedItems = DataService:GetTable(player, "Equipped")
	local folder = player:FindFirstChild("Equipped")
	---Must own the Item---
	if not inventory[itemID] then
		warn(itemID , " Not Found In Inventory")
		return
	end

	---If A Weapon---
	local itemData = ItemDataBase:GetItemData(itemID)
	if itemData then
		if string.find(itemID, "weapon") then
			if equippedItems.Weapons.MainHand ~= itemID and equippedItems.Weapons.OffHand ~= itemID then
				if equippedItems.Weapons.MainHand then
					if equippedItems.Weapons.OffHand then
						EquipService:UnEquipItem(player, equippedItems.Weapons.MainHand)

						local val = folder:FindFirstChild("Weapons"):FindFirstChild("MainHand")
						if not val then
							val = Instance.new("StringValue")
							val.Name = "MainHand"
							val:SetAttribute("ItemID", itemID)
							val.Parent = folder:FindFirstChild("Weapons")
						end
						equippedItems.Weapons.MainHand = itemID
					else
						local val = folder:FindFirstChild("Weapons"):FindFirstChild("OffHand")
						if not val then
							val = Instance.new("StringValue")
							val.Name = "OffHand"
							val:SetAttribute("ItemID", itemID)
							val.Parent = folder:FindFirstChild("Weapons")
						end
						equippedItems.Weapons.OffHand = itemID
					end
				else
					local val = folder:FindFirstChild("Weapons"):FindFirstChild("MainHand")
					if not val then
						val = Instance.new("StringValue")
						val.Name = "MainHand"
						val:SetAttribute("ItemID", itemID)
						val.Parent = folder:FindFirstChild("Weapons")
					end
					equippedItems.Weapons.MainHand = itemID
				end

				local tool: Tool? = ServerStorage.Tools[itemData.Type]:FindFirstChild(itemData.Name):Clone()
				if tool then
					tool.Parent = player.Backpack
					ToolLoader(tool)
				end
			end
		elseif string.find(itemID, "armor") then
			if equippedItems.Armor[itemData.Type] ~= itemID then
				if equippedItems.Armor[itemData.Type] ~= "" then
					EquipService:UnEquipItem(player, equippedItems.Armor[itemData.Type])
				end
				equippedItems.Armor[itemData.Type] = itemID
				local val = folder:FindFirstChild("Armor"):FindFirstChild(itemData.Type)
				if not val then
					val = Instance.new("StringValue")
					val.Name = itemData.Type
					val:SetAttribute("ItemID", itemID)
					val.Parent = folder:FindFirstChild("Armor")
				end

				local armor: Part? = ServerStorage.Armors[itemData.Type]:FindFirstChild(itemData.Name):Clone()
				if armor then
					armor.Parent = char
				end
			end
		end
		if itemData.Buffs then
			BuffService:AddBuff(player, itemData, itemID)
		end
	end

	print(DataService.PlayerDatas[player])
end

function EquipService:UnEquipItem(player: Player, itemID)
	local char = player.Character or player.CharacterAdded:Wait()
	local inventory = DataService:GetTable(player, "Inventory")
	local equippedItems = DataService:GetTable(player, "Equipped")
	local folder = player:FindFirstChild("Equipped")

	-- Must own the Item
	if not inventory[itemID] then
		warn(itemID, " Not Found In Inventory")
		return
	end
	---If A Weapon---
	local itemData = ItemDataBase:GetItemData(itemID)
	if itemData then
		if string.find(itemID, "weapon") then
			if equippedItems.Weapons.MainHand == itemID then
				equippedItems.Weapons.MainHand = nil
				local val = folder:FindFirstChild("Weapons"):FindFirstChild("MainHand")
				if val then
					val:Destroy()
				end
			elseif equippedItems.Weapons.OffHand == itemID then
				equippedItems.Weapons.OffHand = nil
				local val = folder:FindFirstChild("Weapons"):FindFirstChild("OffHand")
				if val then
					val:Destroy()
				end
			end

			local tool: Tool? = player.Backpack:FindFirstChild(itemData.Name) or char:FindFirstChild(itemData.Name)
			local weaponEquippedModel = char:FindFirstChild(itemData.Name .. "_Equipped")
			local weaponUnEquippedModel = char:FindFirstChild(itemData.Name .. "_UnEquipped")
			if tool then
				tool:Destroy()
				if weaponEquippedModel then
					weaponEquippedModel:Destroy()
				end
				if weaponUnEquippedModel then
					weaponUnEquippedModel:Destroy()
				end
			else
				warn("Weapon: " .. itemData.Name .. " Not Found")
			end
		elseif string.find(itemID, "armor") then
			local val = folder:FindFirstChild("Armor"):FindFirstChild(itemData.Type)
			if val then
				val:Destroy()
			end
			equippedItems.Armor[itemData.Type] = nil

			local armor: Part? = char:FindFirstChild(itemData.Name)
			if armor then
				armor:Destroy()
			else
				warn("Armor: " .. itemData.Name .. " Not Found")
			end
		end
		BuffService:RemoveBuff(player, itemData, itemID)
	end

	print(DataService.PlayerDatas[player].Equipped)
end

function EquipService:SetActiveHand(player: Player, itemID)
	local char = player.Character or player.CharacterAdded:Wait()
	local itemData = ItemDataBase:GetItemData(itemID)

	if VitalsService:GetVital(char, "ActiveHand") == itemID then
		local item = char:FindFirstChild(itemData.Name)
		if item then
			item.Parent = player.Backpack
		end
	else
		local anotherItemData = ItemDataBase:GetItemData(VitalsService:GetVital(char, "ActiveHand"))
		if anotherItemData then
			if char:FindFirstChild(itemData.Name) then
				char:FindFirstChild(itemData.Name).Parent = player.Backpack
			end
		end

		local item = player.Backpack:FindFirstChild(itemData.Name)
		if item then
			item.Parent = char
		end
	end

	VitalsService:ModifyVital(char, "ActiveHand", "SetActiveHand", {
		["ItemID"] = itemID,
	})
end

return EquipService
