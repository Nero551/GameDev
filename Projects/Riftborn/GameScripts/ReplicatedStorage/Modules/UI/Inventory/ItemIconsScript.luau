return function  (Frame)
	local repstor = game:GetService("ReplicatedStorage")
	local remotes = repstor.Remotes
	local icons = repstor.Assets.GUI.Icons
	local itemDataBase = require(repstor.Modules.Data.ItemDataBase)

	for _,icon in Frame:GetChildren() do
		if icon:IsA("Frame") then
			icon:Destroy()
		end
	end


	remotes.UpdateInventory.OnClientEvent:Connect(function(inventory, equippedItems)
		for  itemID, item in pairs(inventory) do

			for _,icon in Frame:GetChildren() do
				if icon:IsA("Frame") then
					if not inventory[itemID] then
						icon:Destroy()
					end
				end
			end

			local itemData = itemDataBase:GetItemData(itemID)

			---Getting Rarity---
			local rarity = item.Rarity

			---Adding And Getting Icon---
			local iconFrame = Frame:FindFirstChild(item.Name)
			local icon = nil
			if iconFrame then
				icon = iconFrame:FindFirstChild(item.Name)
			end

			if not iconFrame then
				iconFrame = icons:WaitForChild(rarity.."ItemFrame"):Clone()
				iconFrame.Name = item.Name
				iconFrame.Parent = Frame
				icon = iconFrame[rarity.."Item"]
				icon.Name = iconFrame.Name
			end
			if itemData.Stackable == false then
				icon.OwnedAmount.Visible = false
				icon.NameText.Visible = true
			else
				icon.NameText.Visible = false
				icon.OwnedAmount.Visible = true
			end
			icon.NameText.Text = itemData.Name
			icon.OwnedAmount.Text =   item.Amount
			icon.Icon.Image = itemData.Icon
			
			iconFrame:SetAttribute("IconDescription", itemData.Description)
			iconFrame:SetAttribute("IconRarity", itemData.Rarity)
			iconFrame:SetAttribute("ItemID", itemID)
			iconFrame:SetAttribute("IconType", itemData.Type)

			if equippedItems[item.Type] == itemID then
				iconFrame:SetAttribute("IconEquipState", true)
				icon.EquippedIcon.Visible = true
			else
				iconFrame:SetAttribute("IconEquipState", false)
				icon.EquippedIcon.Visible = false
			end

			iconFrame.Visible = true

		end
	end)

end