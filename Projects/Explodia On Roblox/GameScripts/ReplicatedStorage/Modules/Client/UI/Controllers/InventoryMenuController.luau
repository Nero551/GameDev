local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ReturnButton = require(ReplicatedStorage.Modules.Client.UI.Components.ReturnButton)
local ClickHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.ClickHelper)
local HoverHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.HoverHelper)
local SelectedHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.SelectedHelper)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local RarityData = require(game.ReplicatedStorage.Modules.Data.RarityData)
local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local UIManager = require(game.ReplicatedStorage.Modules.Client.UI.UIManager)

local InventoryMenuController = {}

local player = Players.LocalPlayer

function InventoryMenuController:TopBar()
	ReturnButton("InventoryMenu")

	local itemFrame = UIManager:GetUI("InventoryMenu", "ItemScrollingFrame")
	local Filters = UIManager:GetUI("InventoryMenu", "Filters")

	for _, filter in Filters:GetChildren() do
		if filter:IsA("TextButton") then
			ClickHelper:ClickEffects(filter)
			HoverHelper:HoverEffects(filter)
			SelectedHelper:SelectedEffects(filter, "InventoryFilters")

			filter.MouseButton1Click:Connect(function()
				---Filter---
				local filterType = filter.FilterType.Text

				for _, iconFrame in itemFrame:GetChildren() do
					if iconFrame:IsA("ImageButton") then
						iconFrame.Visible = true
					end
				end

				if filterType ~= "All" then
					for _, iconFrame in itemFrame:GetChildren() do
						if iconFrame:IsA("ImageButton") then
							local iconType = nil

							local itemData = ItemDataBase:GetItemData(iconFrame.Name)
							if itemData then
								if
									itemData.Type == "Helmet"
									or itemData.Type == "ChestPlate"
									or itemData.Type == "Leggings"
									or itemData.Type == "Boots"
								then
									iconType = "Armor"
								end
								if itemData.Type == "Sword" then
									iconType = "Sword"
								end
								if itemData.Type == "Melee" then
									iconType = "Melee"
								end
								if itemData.Type == "Grimore" then
									iconType = "Grimore"
								end
								if itemData.Type == "Material" or itemData.Type == "Resource" then
									iconType = "Material"
								end
							end
							if iconType == filterType then
								iconFrame.Visible = true
							else
								iconFrame.Visible = false
							end
						end
					end
				end
			end)
		end
	end
end

function InventoryMenuController:Inventory()
	local inventory = player:WaitForChild("Inventory")
	local equipped = player:WaitForChild("Equipped")

	local itemFrame = UIManager:GetUI("InventoryMenu", "ItemScrollingFrame")
	local infoFrame = UIManager:GetUI("InventoryMenu", "InfoFrame")
	local infoImage = infoFrame.ItemImage
	local infoName = infoFrame.ItemName.TextLabel
	local infoType = infoFrame.ItemType
	local infoRarity = infoFrame.ItemRarity
	local infoAmountOwned = infoFrame.ItemAmountOwned
	local infoDescription = infoFrame.Description
	local infoMastery = infoFrame.ItemMastery
	local equipIcon = infoFrame:FindFirstChild("Equip")
	local equipButton = equipIcon:FindFirstChild("EquipButton")
	local unequipButton = equipIcon:FindFirstChild("UnEquipButton")

	infoFrame.Visible = false

	for _, itemSlot in itemFrame:GetChildren() do
		if itemSlot:IsA("ImageButton") then
			itemSlot:Destroy()
		end
	end
	local function UpdateUI(descendant: Instance, remove)
		infoFrame.Visible = false
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
				player.PlayerGui.UITemplates.Icons[itemData.Rarity .. "Item"],
				"ItemScrollingFrame"
			)
			itemSlot.Name = itemID
			ClickHelper:ClickEffects(itemSlot)
			HoverHelper:HoverEffects(itemSlot)
			SelectedHelper:SelectedEffects(itemSlot, "InventorySlots")

			local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)


			itemSlot.MouseButton1Click:Connect(function()

				---Info Setup---
				infoFrame:SetAttribute("ItemName", itemData.Name)
				infoFrame:SetAttribute("ItemID", itemID)
				infoImage.Image = itemData.Icon
				infoName.Text = itemData.Name
				infoName.TextColor3 = Color3.fromHex(RarityData[itemData.Rarity].Color)
				infoType.Text = itemData.SubType
				infoRarity.Text = itemData.Rarity
				infoRarity.TextColor3 = Color3.fromHex(RarityData[itemData.Rarity].Color)
				infoAmountOwned.Text = "Owned: " .. tostring(descendant:GetAttribute("Amount"))
				infoFrame.Visible = true
				infoDescription.Text = itemData.Description

				equipIcon.Visible = true
				---If Item Is A Weapon---
				if string.find(infoFrame:GetAttribute("ItemID"), "weapon") then
					infoMastery.Text = "Mastery: " .. tostring(descendant:GetAttribute("Mastery"))
					infoMastery.Visible = true
					---If Item Is An Armor
				elseif string.find(infoFrame:GetAttribute("ItemID"), "armor") then
					infoMastery.Visible = false
				else
					---If Item Is A Material---
					equipIcon.Visible = false
					infoMastery.Visible = false
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
		else
			itemSlot.OwnedAmount.Visible = true
		end

		itemSlot.ItemName.TextLabel.Visible = true
		itemSlot.ItemName.TextLabel.Text = itemData.Name
		itemSlot.OwnedAmount.Text = descendant:GetAttribute("Amount")
		itemSlot.Icon.Image = itemData.Icon

		if
			equipped:FindFirstChild(itemData.Type)
			and equipped:FindFirstChild(itemData.Type):GetAttribute("Equipped") == itemID
		then
			equippedIcon.Visible = true
		else
			equippedIcon.Visible = false
		end
	end

	for _, catagory in equipped:GetChildren() do
		catagory.ChildAdded:Connect(function(child)
			local icon = itemFrame:FindFirstChild(child:GetAttribute("ItemID"))
			if icon then
				icon:FindFirstChild("EquippedIcon").Visible = true
			end
		end)
		catagory.ChildRemoved:Connect(function(child)
			local icon = itemFrame:FindFirstChild(child:GetAttribute("ItemID"))
			if icon then
				icon:FindFirstChild("EquippedIcon").Visible = false
			end
		end)
	end

	for _, descendant in inventory:GetDescendants() do
		descendant.AttributeChanged:Connect(function()
			UpdateUI(descendant)
		end)
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
	local infoFrame = UIManager:GetUI("InventoryMenu", "InfoFrame")
	local box = infoFrame:FindFirstChild("Equip")
	local equipButton = box:FindFirstChild("EquipButton")
	local unequipButton = box:FindFirstChild("UnEquipButton")
	local info = TweenInfo.new(0.0625, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

	HoverHelper:SizeEffect(box)
	HoverHelper:SoundEffect(box)

	ClickHelper:SizeEffect(equipButton)
	ClickHelper:SoundEffect(equipButton)

	ClickHelper:SizeEffect(unequipButton)
	ClickHelper:SoundEffect(unequipButton)

	box.MouseEnter:Connect(function()
		TweenService:Create(box, info, { ImageColor3 = Color3.fromRGB(55, 67, 122) }):Play()
	end)

	box.MouseLeave:Connect(function()
		TweenService:Create(box, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)

	equipButton.MouseButton1Click:Connect(function()
		local itemID = infoFrame:GetAttribute("ItemID")
		NetworkingService:FireToServer("EquipItem", itemID)
		TweenService:Create(equipButton, info, { TextTransparency = 1 }):Play()
		TweenService:Create(unequipButton, info, { TextTransparency = 0 }):Play()
		task.wait(0.0625)
		equipButton.Visible = false
		unequipButton.Visible = true
	end)

	unequipButton.MouseButton1Click:Connect(function()
		local itemID = infoFrame:GetAttribute("ItemID")
		NetworkingService:FireToServer("UnequipItem", itemID)

		TweenService:Create(equipButton, info, { TextTransparency = 0 }):Play()
		TweenService:Create(unequipButton, info, { TextTransparency = 1 }):Play()

		task.wait(info.Time)
		equipButton.Visible = true
		unequipButton.Visible = false
	end)
end

function InventoryMenuController:Search()
	local itemFrame = UIManager:GetUI("InventoryMenu", "ItemScrollingFrame")
	local searchBox = UIManager:GetUI("InventoryMenu", "SearchBox")

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = searchBox.Text:lower()

		for _, icon in itemFrame:GetChildren() do
			if icon:IsA("ImageButton") then
				local itemName = icon.ItemName.TextLabel.Text:lower()

				if text == "" then
					icon.Visible = true
				else
					icon.Visible = false

					for word in string.gmatch(itemName, "%S+") do
						if string.sub(word, 1, #text) == text then
							icon.Visible = true
							break
						end
					end
				end
			end
		end
	end)
end

return InventoryMenuController
