local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local TechniqueData = require(ReplicatedStorage.Modules.Data.TechniqueData)
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local RarityData = require(ReplicatedStorage.Modules.Data.RarityData)
local ArmoryMenuController = {}

function ArmoryMenuController:Armory()
	local player = Players.LocalPlayer
	local inventory = player:WaitForChild("Inventory")
	local equipped = player:WaitForChild("Equipped")
	local armory = UIManager:GetUI("ArmoryMenu", "ArmoryMenu")
	local armoryList = armory:FindFirstChild("ArmoryList")
	local armoryInfo = armory:FindFirstChild("ArmoryInfo")
	local info = TweenInfo.new(0.0625, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

	local itemFrame = armoryList:FindFirstChild("ArmoryScrollingFrame")
	local infoImage = armoryInfo.ItemImage
	local infoName = armoryInfo.ItemName
	local infoType = armoryInfo.ItemType
	local infoRarity = armoryInfo.ItemRarity
	local infoDescription = armoryInfo.Description
	local abiltiesFrame = armoryInfo:FindFirstChild("Abilties")
	local statsFrame = armoryInfo:FindFirstChild("Stats")
	local infoMastery = armoryInfo.ItemMastery
	local equipIcon = armoryInfo:FindFirstChild("Equip")
	local equipButton = equipIcon:FindFirstChild("EquipButton")
	local unequipButton = equipIcon:FindFirstChild("UnEquipButton")

	UIHelper:HoverEffects(equipIcon)
	UIHelper:ClickEffects(equipButton)
	UIHelper:ClickEffects(unequipButton)
	equipIcon.MouseEnter:Connect(function()
		TweenService:Create(equipIcon, info, { ImageColor3 = Color3.fromRGB(55, 67, 122) }):Play()
	end)

	equipIcon.MouseLeave:Connect(function()
		TweenService:Create(equipIcon, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)

	equipButton.MouseButton1Click:Connect(function()
		local itemID = armoryInfo:GetAttribute("ItemID")
		NetworkingService:FireToServer("EquipItem", itemID)
		TweenService:Create(equipButton, info, { TextTransparency = 1 }):Play()
		TweenService:Create(unequipButton, info, { TextTransparency = 0 }):Play()
		task.wait(0.0625)
		equipButton.Visible = false
		unequipButton.Visible = true
	end)

	unequipButton.MouseButton1Click:Connect(function()
		local itemID = armoryInfo:GetAttribute("ItemID")
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

	local IconSelected = nil
	local PrevIconSelected = nil

	for _, itemSlot in itemFrame:GetChildren() do
		if itemSlot:IsA("ImageButton") then
			itemSlot:Destroy()
		end
	end
	local function UpdateUI(descendant: Instance, remove)
		armoryInfo.Visible = false
		local itemID = descendant.Name

		if not string.find(itemID, "weapon") and not string.find(itemID, "armor") then
			print(itemID)
			return
		end
		local itemData = ItemDataBase:GetItemData(itemID)

		local itemSlot = itemFrame:FindFirstChild(itemID)
		if itemSlot and remove then
			itemSlot:Destroy()
			return
		end

		if not itemSlot then
			itemSlot = UIManager:CloneUI(
				"ArmoryMenu",
				itemID,
				ReplicatedStorage.Assets.UI.Icons[itemData.Rarity .. "Item"],
				"ArmoryScrollingFrame"
			)
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
				for _, ability in abiltiesFrame:GetChildren() do
					if ability:IsA("Frame") then
						local techniqueLetter = ability.AbilityLetter.Text
						if itemData.Abilities then
							local techniqueData = TechniqueData:GetTechniqueData(itemData.Abilities[techniqueLetter])
							if not techniqueData then
								ability.Visible = false
							else
								ability.Visible = true
								ability.AbilityMastery.Text = techniqueData.Mastery
								ability.AbilityName.Text = techniqueData.TechniqueName
							end
						else
							ability.Visible = false
						end
					end
				end

				for _, Stat in statsFrame:GetChildren() do
					if not Stat:IsA("Frame") then
						continue
					end
					local statCatagory: TextLabel = Stat.StatCatagory.Text
					local statNumber: TextLabel = Stat.StatNumber
					if itemData[statCatagory] == nil then
						if itemData.Buffs then
							if itemData.Buffs[statCatagory] == nil then
								Stat.Visible = false
								statNumber.Text = ""
							else
								Stat.Visible = true
								if itemData.Buffs[statCatagory].Percent then
									statNumber.Text = "+" .. (itemData.Buffs[statCatagory].Percent * 100) .. "%"
								else
									statNumber.Text = "+" .. itemData.Buffs[statCatagory].Flat
								end
							end
						else
							Stat.Visible = false
							statNumber.Text = ""
						end
					else
						Stat.Visible = true
						if Stat.Name == "CriticalRate" or Stat.Name == "CriticalDamage" then
							statNumber.Text = (itemData[statCatagory] * 100) .. "%"
						else
							statNumber.Text = itemData[statCatagory]
						end
					end
				end

				armoryInfo:SetAttribute("ItemName", itemData.Name)
				armoryInfo:SetAttribute("ItemID", itemID)
				infoImage.Image = itemData.Icon
				infoName.Text = itemData.Name
				infoName.TextColor3 = Color3.fromHex(RarityData[itemData.Rarity].Color)
				infoType.Text = itemData.SubType
				infoRarity.Text = itemData.Rarity
				infoRarity.TextColor3 = Color3.fromHex(RarityData[itemData.Rarity].Color)
				armoryInfo.Visible = true
				infoDescription.Text = itemData.Description
				equipIcon.Visible = true
				statsFrame.Visible = true

				---If Item Is A Weapon---
				if string.find(itemID, "weapon") then
					infoMastery.Text = "Mastery: " .. tostring(descendant:GetAttribute("Mastery"))
					infoMastery.Visible = true
					abiltiesFrame.Visible = true
					---If Item Is An Armor
				elseif string.find(itemID, "armor") then
					infoMastery.Visible = false
					abiltiesFrame.Visible = false
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
		itemSlot.NameText.Text = itemData.Name
		itemSlot.Icon.Image = itemData.Icon
		if itemSlot:FindFirstChild("OwnedAmount") then
			itemSlot:FindFirstChild("OwnedAmount"):Destroy()
		end
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

function ArmoryMenuController:Search()
	local itemFrame = UIManager:GetUI("ArmoryMenu", "ArmoryScrollingFrame")
	local searchBox = UIManager:GetUI("ArmoryMenu", "SearchBox")

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

return ArmoryMenuController
