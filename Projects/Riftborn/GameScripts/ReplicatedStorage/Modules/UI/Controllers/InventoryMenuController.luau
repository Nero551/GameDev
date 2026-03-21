local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local AbilityData = require(ReplicatedStorage.Modules.Data.AbilityData)
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local RarityData = require(ReplicatedStorage.Modules.Data.RarityData)
local NetworkingService = require(ReplicatedStorage.Modules.NetworkingService)
local UIHelper = require(ReplicatedStorage.Modules.UI.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.UI.UIManager)

local InventoryMenuController = {}

local player = Players.LocalPlayer

function InventoryMenuController:Inventory()
	local inventory = player:WaitForChild("Inventory")
	local equipped = player:WaitForChild("Equipped")

	local itemFrame = UIManager:GetUI("InventoryMenu", "ItemScrollingFrame")
	local infoFrame = UIManager:GetUI("InventoryMenu", "InfoFrame")
	local infoImage = infoFrame.ItemImage
	local infoName = infoFrame.ItemName
	local infoType = infoFrame.ItemType
	local infoRarity = infoFrame.ItemRarity
	local infoAmountOwned = infoFrame.ItemAmountOwned
	local infoNonWeaponDesc = infoFrame.NonWeaponDescription
	local infoWeaponDesc = infoFrame.WeaponDescription
	local infoWeaponDescButton = infoFrame["WeaponDescriptionButton(HoverClickSoundSizeChange)"]
	local infoMastery = infoFrame.ItemMastery
	local abilitiesFrame = infoFrame.Abilties
	local equipIcon = infoFrame:FindFirstChild("Equip")
	local equipButton = equipIcon:FindFirstChild("EquipButton")
	local unequipButton = equipIcon:FindFirstChild("UnEquipButton")

	local baseStatsButton = infoFrame["BaseStatsButton(HoverClickSoundSizeChange)"]
	local IconSelected = nil
	local PrevIconSelected = nil

	infoFrame.Visible = false

	local infoNameStroke = infoName:FindFirstChild("UIStroke")
	local innerStroke = infoFrame:FindFirstChild("InnerStroke")
	local outerStroke = infoFrame:FindFirstChild("OuterStroke")

	UIHelper:RotateGradient(infoNameStroke:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(innerStroke:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(outerStroke:FindFirstChild("UIGradient"))

	for _, ability in abilitiesFrame:GetChildren() do
		if ability:IsA("Frame") then
			local RGBStroke = ability:FindFirstChild("AbilityIcon"):FindFirstChild("RGBStroke")
			UIHelper:RotateGradient(RGBStroke:FindFirstChild("UIGradient"))
		end
	end

	for _, itemSlot in itemFrame:GetChildren() do
		if itemSlot:IsA("ImageButton") then
			itemSlot:Destroy()
		end
	end
	local function UpdateUI(descendant: Instance, remove)
		local itemID = descendant.Name
		local itemData = ItemDataBase:GetItemData(itemID)

		local itemSlot = itemFrame:FindFirstChild(itemID)
		if itemSlot and remove then
			itemSlot:Destroy()
			return
		end

		if not itemSlot then
			itemSlot = UIManager:CloneUI(
				"InventoryMenu",
				itemID,
				ReplicatedStorage.Assets.GUI.Icons[itemData.Rarity .. "Item"],
				"ItemScrollingFrame"
			)
			print("nice", itemSlot)
			itemSlot.Name = itemID
			UIHelper:ClickEffects(itemSlot)
			UIHelper:HoverEffects(itemSlot)

			local border = itemSlot:FindFirstChild("Border")
			UIHelper:RotateGradient(border:FindFirstChild("UIGradient"))

			local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			itemSlot.MouseEnter:Connect(function()
				itemSlot.ImageColor3 = Color3.fromHex("#eeeeee")
				if IconSelected ~= itemSlot then
					TweenService:Create(border, info, { ImageColor3 = Color3.fromRGB(71, 88, 158) }):Play()
				end
			end)

			itemSlot.MouseLeave:Connect(function()
				itemSlot.ImageColor3 = Color3.fromHex("#ffffff")
				if IconSelected ~= itemSlot then
					TweenService:Create(border, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				end
			end)

			itemSlot.MouseButton1Click:Connect(function()
				PrevIconSelected = IconSelected
				IconSelected = itemSlot
				if IconSelected ~= nil then
					TweenService:Create(IconSelected.Border, info, { ImageColor3 = Color3.fromRGB(114, 142, 255) })
						:Play()
				end
				if PrevIconSelected ~= nil and PrevIconSelected ~= IconSelected then
					TweenService:Create(PrevIconSelected.Border, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
						:Play()
				end

				for _, ability in abilitiesFrame:GetChildren() do
					if ability:IsA("Frame") then
						local abilityLetter = ability.AbilityIcon.AbilityLetter.Text
						local abilityData = AbilityData:GetAbilityData(itemData.Name .. abilityLetter)
						if not abilityData then
							ability.Visible = false
						else
							ability.Visible = true
							ability.AbilityMastery.Text = abilityData.AbilityMastery
							ability.AbilityName.Text = abilityData.AbilityName
						end
					end
				end

				---Info Setup---
				infoFrame:SetAttribute("ItemName", itemData.Name)
				infoFrame:SetAttribute("ItemID", itemID)
				infoImage.Image = itemData.Icon
				infoName.Text = itemData.Name
				infoName.TextColor3 = Color3.fromHex(RarityData[itemData.Rarity].Color)
				infoType.Text = itemData.Type
				infoRarity.Text = itemData.Rarity
				infoRarity.TextColor3 = Color3.fromHex(RarityData[itemData.Rarity].Color)
				infoAmountOwned.Text = "Owned: " .. tostring(descendant:GetAttribute("Amount"))
				infoFrame.Visible = true

				---If Item Is A Weapon---
				if infoType.Text == "Sword" or infoType.Text == "Melee" then
					abilitiesFrame.Position = UDim2.fromScale(0.043, 0.428)
					infoWeaponDesc.Position = UDim2.fromScale(-1, 0.428)
					baseStatsButton.Visible = true
					abilitiesFrame.Visible = true
					equipIcon.Visible = true
					infoNonWeaponDesc.Visible = false
					infoWeaponDescButton.Visible = true
					infoWeaponDesc.Visible = true
					infoMastery.Visible = true
					infoWeaponDesc.Text = itemData.Description
					---If Item Is An Armor
				elseif
					infoType.Text == "Helmet"
					or infoType.Text == "ChestPlate"
					or infoType.Text == "Leggings"
					or infoType.Text == "Boots"
				then
					infoWeaponDesc.Visible = false
					infoWeaponDescButton.Visible = false
					infoNonWeaponDesc.Visible = true
					baseStatsButton.Visible = true
					equipIcon.Visible = true
					infoMastery.Visible = false
					infoNonWeaponDesc.Text = itemData.Description
				else
					---If Item Is A Material---
					infoWeaponDesc.Visible = false
					infoWeaponDescButton.Visible = false
					infoNonWeaponDesc.Visible = true
					baseStatsButton.Visible = false
					equipIcon.Visible = false
					infoMastery.Visible = false
					infoNonWeaponDesc.Text = itemData.Description
				end

				if
					equipped:FindFirstChild(itemData.Type)
					and equipped:FindFirstChild(itemData.Type):GetAttribute("Equipped") == itemID
				then
					TweenService:Create(equipButton, info, { TextTransparency = 1 }):Play()
					TweenService:Create(unequipButton, info, { TextTransparency = 0 }):Play()
					equipButton.Visible = false
					unequipButton.Visible = true
				else
					TweenService:Create(equipButton, info, { TextTransparency = 0 }):Play()
					TweenService:Create(unequipButton, info, { TextTransparency = 1 }):Play()
					equipButton.Visible = true
					unequipButton.Visible = false
				end
			end)
		end
		local equippedIcon = itemSlot:FindFirstChild("EquippedIcon")
		if itemData.Stackable == false then
			itemSlot.OwnedAmount.Visible = false
			itemSlot.NameText.Visible = true
		else
			itemSlot.NameText.Visible = false
			itemSlot.OwnedAmount.Visible = true
		end
		itemSlot.NameText.Text = itemData.Name
		itemSlot.OwnedAmount.Text = descendant:GetAttribute("Amount")
		itemSlot.Icon.Image = itemData.Icon

		descendant.AttributeChanged:Connect(function()
			itemSlot.NameText.Text = itemData.Name
			itemSlot.OwnedAmount.Text = descendant:GetAttribute("Amount")
			itemSlot.Icon.Image = itemData.Icon
		end)

		itemSlot:SetAttribute("ItemID", itemID)
		if
			equipped:FindFirstChild(itemData.Type)
			and equipped:FindFirstChild(itemData.Type):GetAttribute("Equipped") == itemID
		then
			equippedIcon.Visible = true
		else
			equippedIcon.Visible = false
		end
	end

	for _, descendant in inventory:GetDescendants() do
		UpdateUI(descendant)
	end

	inventory.DescendantAdded:Connect(function(descendant)
		UpdateUI(descendant)
	end)

	inventory.DescendantRemoving:Connect(function(descendant)
		UpdateUI(descendant, true)
	end)
end

function InventoryMenuController:Equip()
	local itemFrame = UIManager:GetUI("InventoryMenu", "ItemScrollingFrame")
	local infoFrame = UIManager:GetUI("InventoryMenu", "InfoFrame")
	local box = infoFrame:FindFirstChild("Equip")
	local equipButton = box:FindFirstChild("EquipButton")
	local unequipButton = box:FindFirstChild("UnEquipButton")
	local RGBStroke = box:FindFirstChild("RGBStroke")
	local info = TweenInfo.new(0.0625, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

	UIHelper:RotateGradient(RGBStroke:FindFirstChild("UIGradient"))
	UIHelper:HoverEffects(box)
	UIHelper:ClickEffects(equipButton)
	UIHelper:ClickEffects(unequipButton)

	box.MouseEnter:Connect(function()
		TweenService:Create(box, info, { ImageColor3 = Color3.fromRGB(55, 67, 122) }):Play()
	end)

	box.MouseLeave:Connect(function()
		TweenService:Create(box, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)

	equipButton.MouseButton1Click:Connect(function()
		local itemID = infoFrame:GetAttribute("ItemID")
		NetworkingService:FireToServer("EquipItem", itemID)

		local icon = itemFrame:FindFirstChild(itemID)
		if icon then
			icon:FindFirstChild("EquippedIcon").Visible = true
		end
		TweenService:Create(equipButton, info, { TextTransparency = 1 }):Play()
		TweenService:Create(unequipButton, info, { TextTransparency = 0 }):Play()
		task.wait(0.0625)
		equipButton.Visible = false
		unequipButton.Visible = true
	end)

	unequipButton.MouseButton1Click:Connect(function()
		local itemID = infoFrame:GetAttribute("ItemID")
		NetworkingService:FireToServer("UnequipItem", itemID)

		local icon = itemFrame:FindFirstChild(itemID)
		if icon then
			icon:FindFirstChild("EquippedIcon").Visible = false
		end
		TweenService:Create(equipButton, info, { TextTransparency = 0 }):Play()
		TweenService:Create(unequipButton, info, { TextTransparency = 1 }):Play()
		task.wait(0.0625)
		equipButton.Visible = true
		unequipButton.Visible = false
	end)
end

return InventoryMenuController
