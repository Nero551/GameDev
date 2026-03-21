local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ToolLoader = ModuleLoader:Load("Server", "ToolLoader")
local ItemDataBase = ModuleLoader:Load("Shared", "ItemDataBase")
local GameEvents = ModuleLoader:Load("Shared", "GameEvents")

local DataService = ModuleLoader:Load("Server", "DataService")

local EquipService = {}

function EquipService:SetupEquipped(player)
	local folder = player:FindFirstChild("Equipped")
	local EquippedItems = DataService:GetTable(player, "Equipped")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Equipped"
		folder.Parent = player
	end

	for type, itemID in pairs(EquippedItems) do
		local value = folder:FindFirstChild(type)
		if not value then
			value = Instance.new("StringValue")
			value.Name = type
			value.Parent = folder
		end
		value:SetAttribute("Equipped", itemID)
	end
	EquipService:LoadEquippedItems(player)
end

---Equip Weapon---
function EquipService:EquipItem(player: Player, itemID)
	local inventory = DataService:GetTable(player, "Inventory")
	local equippedItems = DataService:GetTable(player, "Equipped")
	---Must own the Item---
	if not inventory[itemID] then
		warn(itemID .. " Not Found In Inventory")
		return
	end
	local char = player.Character or player.CharacterAdded:Wait()
	local itemType = nil

	---If A Weapon---
	local itemData = ItemDataBase:GetItemData(itemID)
	if itemData then
		if
			itemData.Type == "Melee"
			or itemData.Type == "Sword"
			or itemData.Type == "Grimiore"
			or itemData.Type == "RiftBorn"
		then
			print(itemData)
			itemType = itemData.Type
			local tool: Tool? = ServerStorage.Tools[itemType]:FindFirstChild(itemData.Name):Clone()
			if tool then
				--Check For Another Tool With Same Type--
				for _, anotherTool in char:GetChildren() do
					if anotherTool:IsA("Tool") then
						local anotherToolData = ItemDataBase:GetItemData(anotherTool:GetAttribute("ID"))
						if anotherToolData.Buffs then
							GameEvents.RemoveBuff:Fire(player, anotherToolData, anotherTool:GetAttribute("ID"))
						end
						anotherTool:Destroy()
					end
					if anotherTool:IsA("Model") and string.find(anotherTool.Name, "_Equipped") then
						anotherTool:Destroy()
					end
				end

				for _, anotherTool in player.Backpack:GetChildren() do
					if anotherTool:IsA("Tool") then
						local anotherToolData = ItemDataBase:GetItemData(anotherTool:GetAttribute("ID"))
						if anotherToolData.Buffs then
							GameEvents.RemoveBuff:Fire(player, anotherToolData, anotherTool:GetAttribute("ID"))
						end
						anotherTool:Destroy()
					end
					if anotherTool:IsA("Model") and string.find(anotherTool.Name, "_Equipped") then
						anotherTool:Destroy()
					end
				end


				tool.Parent = player.Backpack
				ToolLoader(tool)
				if itemData.Buffs then
					GameEvents.AddBuff:Fire(player, itemData, itemID)
				end
			end
		elseif
			itemData.Type == "Helmet"
			or itemData.Type == "ChestPlate"
			or itemData.Type == "Leggings"
			or itemData.Type == "Boots"
		then
			itemType = itemData.Type
			local armor: Part? = ServerStorage.Armors[itemType]:FindFirstChild(itemData.Name):Clone()
			if armor then
				--Check For Another Armor With Same Type--
				for _, anotherArmor in char:GetChildren() do
					if anotherArmor:GetAttribute("Type") == itemType then
						local anotherArmorData = ItemDataBase:GetItemData(anotherArmor:GetAttribute("ID"))
						if anotherArmorData.Buffs then
							GameEvents.RemoveBuff:Fire(player, anotherArmorData, anotherArmor:GetAttribute("ID"))
						end
						anotherArmor:Destroy()
					end
				end
				armor.Parent = char
				if itemData.Buffs then
					GameEvents.AddBuff:Fire(player, itemData, itemID)
				end
			end
		end
	end
	if equippedItems[itemType] ~= itemID then
		equippedItems[itemType] = itemID
	end

	local folder = player:FindFirstChild("Equipped")
	local value = folder:FindFirstChild(itemType)
	if not value then
		value = Instance.new("StringValue")
		value.Name = itemType
		value.Parent = folder
	end
	value:SetAttribute("Equipped", itemID)
	GameEvents.UpdateMana:Fire(player)
end

---UnEquip Item---
function EquipService:UnEquipItem(player: Player, itemID)
	local inventory = DataService:GetTable(player, "Inventory")
	local equippedItems = DataService:GetTable(player, "Equipped")
	-- Must own the Item
	if not inventory[itemID] then
		warn(itemID .. " Not Found In Inventory")
		return
	end
	local char = player.Character or player.CharacterAdded:Wait()
	local itemType = nil

	---If A Weapon---
	local itemData = ItemDataBase:GetItemData(itemID)
	if itemData then
		if
			itemData.Type == "Melee"
			or itemData.Type == "Sword"
			or itemData.Type == "Grimiore"
			or itemData.Type == "RiftBorn"
		then
			itemType = itemData.Type
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
		elseif
			itemData.Type == "Helmet"
			or itemData.Type == "ChestPlate"
			or itemData.Type == "Leggings"
			or itemData.Type == "Boots"
		then
			itemType = itemData.Type
			local armor: Part? = char:FindFirstChild(itemData.Name)
			if armor then
				armor:Destroy()
			else
				warn("Armor: " .. itemData.Name .. " Not Found")
			end
		end
		GameEvents.RemoveBuff:Fire(player, itemData, itemID)
	end
	equippedItems[itemType] = nil
	local folder = player:FindFirstChild("Equipped")
	local value = folder:FindFirstChild(itemType)
	if value then
		value:Destroy()
	end
	GameEvents.UpdateMana:Fire(player)
end

---Load Equipped Items---
function EquipService:LoadEquippedItems(player: Player)
	local inventory = DataService:GetTable(player, "Inventory")
	local equippedItems = DataService:GetTable(player, "Equipped")

	for itemType, itemID in equippedItems do
		---Must own the Item---
		if not inventory[itemID] then
			warn(itemID .. " Not Found In Inventory")
			continue
		end
		local char = player.Character or player.CharacterAdded:Wait()

		---If  A Weapon---
		local itemData = ItemDataBase:GetItemData(itemID)
		if itemData then
			if
				itemData.Type == "Melee"
				or itemData.Type == "Sword"
				or itemData.Type == "Grimiore"
				or itemData.Type == "RiftBorn"
			then
				if itemData.Buffs then
					GameEvents.AddBuff:Fire(player, itemData, itemID)
				end

				itemType = itemData.Type

				--Check For Another Tool With Same Type--
				for _, anotherTool in player.Backpack:GetChildren() do
					if anotherTool:GetAttribute("Type") == itemType then
						anotherTool:Destroy()
					end
				end

				---Cloning Equipped Tools---
				local tool = player.Backpack:FindFirstChild(itemData.Name)
				if not tool then
					tool = ServerStorage.Tools[itemType]:FindFirstChild(itemData.Name):Clone()
					tool.Parent = player.Backpack
					ToolLoader(tool)
				end
			elseif
				itemData.Type == "Helmet"
				or itemData.Type == "ChestPlate"
				or itemData.Type == "Leggings"
				or itemData.Type == "Boots"
			then
				if itemData.Buffs then
					GameEvents.AddBuff:Fire(player, itemData, itemID)
				end
				itemType = itemData.Type

				---Cloning Equipped Armor---
				local armor = char:FindFirstChild(itemData.Name)
				if not armor then
					armor = ServerStorage.Armors[itemType]:FindFirstChild(itemData.Name):Clone()
					armor.Parent = char
				end
			end
		end
	end

	GameEvents.UpdateMana:Fire(player)
end

return EquipService
