local serverStorage = game:GetService("ServerStorage")
local repstor = game:GetService("ReplicatedStorage")
local itemDataBase = require(repstor.Modules.ItemDataBase)
local GameEvents = require(repstor.Modules.GameEvents)

local DataService = require(script.Parent.Parent.ServerModules.DataService)

local EquipUnEquipService = {}

---Equip Weapon---
function  EquipUnEquipService:EquipItem(player:Player , itemID)
	local inventory = DataService:GetTable(player, "Inventory")
	local equippedItems = DataService:GetTable(player, "Equipped")
	---Must own the Item---
	if not inventory[itemID] then warn(itemID.." Not Found In Inventory") return end
	local char = player.Character or player.CharacterAdded:Wait()
	local itemType = nil

	---If A Weapon---
	local itemData = itemDataBase:GetItemData(itemID)
	if itemData then
		if itemData.Type == "Melee" or itemData.Type == "Sword" or itemData.Type == "Grimiore" or itemData.Type == "RiftBorn" then
			print(itemData)
			itemType = itemData.Type
			local tool:Tool? = serverStorage.Tools[itemType]:FindFirstChild(itemData.Name):Clone()
			if tool then

				--Check For Another Tool With Same Type--
				for _,anotherTool:Tool? in char:GetChildren() do
					if anotherTool:IsA("Tool") then
						local anotherWeaponData = itemDataBase:GetItemData(anotherTool:GetAttribute("ID"))
						if anotherWeaponData.Type == itemType then
							local anotherWeaponEquippedModel = char:FindFirstChild(anotherTool.Name.."_Equipped")
							local anotherWeaponUnEquippedModel = char:FindFirstChild(anotherTool.Name.."_UnEquipped")
							if anotherWeaponData.Buffs then
								GameEvents.RemoveBuff:Fire(player ,  anotherWeaponData,anotherTool:GetAttribute("ID"))
							end
							anotherTool:Destroy()
							anotherWeaponEquippedModel:Destroy()
							anotherWeaponUnEquippedModel:Destroy()
						end
					end
				end

				for _,anotherTool:Tool? in player.Backpack:GetChildren() do
					if anotherTool:IsA("Tool") then
						local anotherWeaponData = itemDataBase:GetItemData(anotherTool:GetAttribute("ID"))
						if anotherWeaponData.Type == itemType then
							local anotherWeaponEquippedModel = char:FindFirstChild(anotherTool.Name.."_Equipped")
							local anotherWeaponUnEquippedModel = char:FindFirstChild(anotherTool.Name.."_UnEquipped")
							if anotherWeaponData.Buffs then
								GameEvents.RemoveBuff:Fire(player ,  anotherWeaponData,anotherTool:GetAttribute("ID"))
							end
							anotherTool:Destroy()
							anotherWeaponEquippedModel:Destroy()
							anotherWeaponUnEquippedModel:Destroy()
						end
					end
				end

				tool.Parent = player.Backpack
				if itemData.Buffs then
					GameEvents.AddBuff:Fire(player,  itemData, itemID)
				end
			end	
			
		elseif itemData.Type == "Helmet" or itemData.Type == "ChestPlate" or itemData.Type == "Leggings" or itemData.Type == "Boots" then
			itemType = itemData.Type
			local armor:Part? = serverStorage.Armors[itemType]:FindFirstChild(itemData.Name):Clone()
			if armor then

				--Check For Another Armor With Same Type--
				for _,anotherArmor:Accessory? in char:GetChildren() do
					if anotherArmor:GetAttribute("Type") == itemType then
						local anotherArmorData = itemDataBase:GetItemData(anotherArmor:GetAttribute("ID"))
						if anotherArmorData.Buffs then
							GameEvents.RemoveBuff:Fire(player ,  anotherArmorData, anotherArmor:GetAttribute("ID"))
						end
						anotherArmor:Destroy()
					end
				end
				armor.Parent = char
				if itemData.Buffs then
					GameEvents.AddBuff:Fire(player,  itemData, itemID)
				end
			end	
		end	
	end	
	if  equippedItems[itemType] ~= itemID  then
		equippedItems[itemType] = itemID
	end
	
	GameEvents.UpdateMana:Fire(player)
	repstor.Remotes.UpdateInventory:FireClient(player, inventory, equippedItems)
	repstor.Remotes.UpdateInventoryInfo:FireClient(player, inventory, equippedItems)
	repstor.Remotes.UpdateEquippedItems:FireClient(player, inventory, equippedItems)

end

---UnEquip Item---
function EquipUnEquipService:UnEquipItem(player:Player ,itemID)
	local inventory = DataService:GetTable(player, "Inventory")
	local equippedItems = DataService:GetTable(player, "Equipped")
	-- Must own the Item
	if not inventory[itemID] then  warn(itemID.." Not Found In Inventory") return end
	local char = player.Character or player.CharacterAdded:Wait()
	local itemType = nil

	---If A Weapon--- 
	local itemData = itemDataBase:GetItemData(itemID)
	if  itemData then
		if itemData.Type == "Melee" or itemData.Type == "Sword" or itemData.Type == "Grimiore" or itemData.Type == "RiftBorn" then
			itemType = itemData.Type
			local tool:Tool? = player.Backpack:FindFirstChild(itemData.Name) or char:FindFirstChild(itemData.Name)
			local weaponEquippedModel = char:FindFirstChild(itemData.Name.."_Equipped")
			local weaponUnEquippedModel = char:FindFirstChild(itemData.Name.."_UnEquipped")
			if tool then
				tool:Destroy()
				if weaponEquippedModel then
					weaponEquippedModel:Destroy()
				end
				if weaponUnEquippedModel then
					weaponUnEquippedModel:Destroy()
				end
				GameEvents.RemoveBuff:Fire(player ,  itemData, itemID)
			else
				warn("Weapon: "..itemData.Name.." Not Found")
			end
			
		elseif itemData.Type == "Helmet" or itemData.Type == "ChestPlate" or itemData.Type == "Leggings" or itemData.Type == "Boots" then
			itemType = itemData.Type
			local armor:Part? = char:FindFirstChild(itemData.Name)
			if armor then
				armor:Destroy()
				GameEvents.RemoveBuff:Fire(player ,  itemData, itemID)
			else
				warn("Armor: "..itemData.Name.." Not Found")
			end
		end
	end	
	equippedItems[itemType] = nil
	GameEvents.UpdateMana:Fire(player)
	repstor.Remotes.UpdateInventory:FireClient(player, inventory, equippedItems)
	repstor.Remotes.UpdateInventoryInfo:FireClient(player, inventory, equippedItems)
	repstor.Remotes.UpdateEquippedItems:FireClient(player, inventory, equippedItems)
end

---Load Equipped Items---
function EquipUnEquipService:LoadEquippedItems(player:Player)
	local inventory = DataService:GetTable(player, "Inventory")
	local equippedItems = DataService:GetTable(player, "Equipped")

	for  itemType, itemID in equippedItems do
		
		---Must own the Item---
		if not inventory[itemID] then warn(itemID.." Not Found In Inventory") return end
		local char = player.Character or player.CharacterAdded:Wait()
		
		---If  A Weapon---
		local itemData = itemDataBase:GetItemData(itemID)
		if  itemData then
			if itemData.Type == "Melee" or itemData.Type == "Sword" or itemData.Type == "Grimiore" or itemData.Type == "RiftBorn" then
				if itemData.Buffs then
					GameEvents.AddBuff:Fire(player,  itemData, itemID)
				end

				itemType = itemData.Type
				local tool:Tool? = serverStorage.Tools[itemType]:FindFirstChild(itemData.Name):Clone()

				--Check For Another Tool With Same Type--
				for _,anotherTool:Tool? in char:GetChildren() or player.Backpack:GetChildren() do
					if anotherTool:GetAttribute("Type") == itemType then
						anotherTool:Destroy()
					end
				end
				tool.Parent = player.Backpack
				
			elseif itemData.Type == "Helmet" or itemData.Type == "ChestPlate" or itemData.Type == "Leggings" or itemData.Type == "Boots" then
				if itemData.Buffs then
					GameEvents.AddBuff:Fire(player,  itemData,itemID)
				end
				itemType = itemData.Type
				local armor:Model? = serverStorage.Armors[itemType]:FindFirstChild(itemData.Name):Clone()

				--Check For Another Armor With Same Type--
				for _,anotherArmor:Accessory? in char:GetChildren() do
					if anotherArmor:GetAttribute("Type") == itemType then
						anotherArmor:Destroy()
					end
				end
				armor.Parent = char
			end
		end
	end
	GameEvents.UpdateMana:Fire(player)
end

return EquipUnEquipService 
