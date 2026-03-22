local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ReturnButton = require(ReplicatedStorage.Modules.Client.UI.Components.ReturnButton)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local RarityData = require(game.ReplicatedStorage.Modules.Data.RarityData)
local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local UIHelper = require(game.ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(game.ReplicatedStorage.Modules.Client.UI.UIManager)

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
	local infoDescription = infoFrame.Description
	local infoMastery = infoFrame.ItemMastery
	local equipIcon = infoFrame:FindFirstChild("Equip")
	local equipButton = equipIcon:FindFirstChild("EquipButton")
	local unequipButton = equipIcon:FindFirstChild("UnEquipButton")

	local IconSelected = nil
	local PrevIconSelected = nil

	ReturnButton(UIManager:GetUI("InventoryMenu", "InventoryMenu"), UIManager:GetUI("InventoryMenu", "ReturnButton"))

	infoFrame.Visible = false

	local infoNameStroke = infoName:FindFirstChild("UIStroke")
	local innerStroke = infoFrame:FindFirstChild("InnerStroke")
	local outerStroke = infoFrame:FindFirstChild("OuterStroke")

	UIHelper:RotateGradient(infoNameStroke:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(innerStroke:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(outerStroke:FindFirstChild("UIGradient"))

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
				ReplicatedStorage.Assets.UI.Icons[itemData.Rarity .. "Item"],
				"ItemScrollingFrame"
			)
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
				infoDescription.Text = itemData.Description

				---If Item Is A Weapon---
				if infoType.Text == "Sword" or infoType.Text == "Melee" then
					equipIcon.Visible = true
					infoMastery.Visible = true
					---If Item Is An Armor
				elseif
					infoType.Text == "Helmet"
					or infoType.Text == "ChestPlate"
					or infoType.Text == "Leggings"
					or infoType.Text == "Boots"
				then
					equipIcon.Visible = true
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
	local equipped = player:WaitForChild("Equipped")
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
		task.wait(0.0625)
		equipButton.Visible = true
		unequipButton.Visible = false
	end)

	equipped.ChildAdded:Connect(function(child)
		local icon = itemFrame:FindFirstChild(child:GetAttribute("Equipped"))
		if icon then
			icon:FindFirstChild("EquippedIcon").Visible = true
		end
	end)

	equipped.ChildRemoved:Connect(function(child)
		local icon = itemFrame:FindFirstChild(child:GetAttribute("Equipped"))
		if icon then
			icon:FindFirstChild("EquippedIcon").Visible = false
		end
	end)
end

function InventoryMenuController:Search()
	local itemFrame = UIManager:GetUI("InventoryMenu", "ItemScrollingFrame")
	local searchBox = UIManager:GetUI("InventoryMenu", "SearchBox")

	UIHelper:RotateGradient(searchBox.Parent:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(searchBox.Parent:FindFirstChild("RGBStroke"):FindFirstChild("UIGradient"))

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = searchBox.Text:lower()

		for _, icon in itemFrame:GetChildren() do
			if icon:IsA("ImageButton") then
				local itemName = icon.NameText.Text:lower()

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

function InventoryMenuController:RandomGradients()
	local Texture = UIManager:GetUI("InventoryMenu", "InventoryMenu").Parent:FindFirstChild("Texture")
	local topBar = UIManager:GetUI("InventoryMenu", "TopBar")
	UIHelper:RotateGradient(topBar:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(Texture:FindFirstChild("UIGradient"))
end

function InventoryMenuController:Filter()
	-- local Filters =
	local itemFrame = UIManager:GetUI("InventoryMenu", "ItemScrollingFrame")
	local Filters = UIManager:GetUI("InventoryMenu", "Filters")
	local filterSelected = nil
	local prevFilterSelected = nil
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, filter in Filters:GetChildren() do
		if filter:IsA("ImageButton") then
			UIHelper:ClickEffects(filter)
			UIHelper:HoverEffects(filter)
			UIHelper:RotateGradient(filter:FindFirstChild("UIGradient"))
			UIHelper:RotateGradient(filter:FindFirstChild("RGBStroke"):FindFirstChild("UIGradient"))

			filter.MouseEnter:Connect(function()
				if filterSelected ~= filter then
					TweenService:Create(filter, info, { ImageColor3 = Color3.fromRGB(87, 107, 194) }):Play()
				end
			end)

			filter.MouseLeave:Connect(function()
				if filterSelected ~= filter then
					TweenService:Create(filter, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				end
			end)

			filter.MouseButton1Click:Connect(function()
				prevFilterSelected = filterSelected
				filterSelected = filter

				if filterSelected ~= nil then
					TweenService
						:Create(filterSelected["FilterType"], info, { TextColor3 = Color3.fromRGB(255, 154, 213) })
						:Play()
					TweenService:Create(filterSelected.RGBStroke, info, { ImageColor3 = Color3.fromRGB(255, 154, 213) })
						:Play()
					TweenService:Create(filterSelected, info, { ImageColor3 = Color3.fromRGB(60, 49, 88) }):Play()
					if prevFilterSelected ~= nil then
						if prevFilterSelected ~= filterSelected then
							TweenService
								:Create(prevFilterSelected, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
								:Play()
							TweenService
								:Create(
									prevFilterSelected.RGBStroke,
									info,
									{ ImageColor3 = Color3.fromRGB(255, 255, 255) }
								)
								:Play()
							TweenService:Create(
								prevFilterSelected["FilterType"],
								info,
								{ TextColor3 = Color3.fromRGB(255, 255, 255) }
							):Play()
						end
					end
				end
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



return InventoryMenuController