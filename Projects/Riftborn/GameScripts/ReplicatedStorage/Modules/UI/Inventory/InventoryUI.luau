local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
return function  (Frame)
local TweenService = game:GetService("TweenService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local icons = ReplicatedStorage.Assets.GUI.Icons
	local infoFrame = Frame.Parent.Parent.Parent.InfoFrame

	local infoImage = infoFrame.ItemImage
	local infoText = infoFrame.ItemName
	local infoType = infoFrame.ItemType
	local infoRarity = infoFrame.ItemRarity
	local infoAmountOwned = infoFrame.ItemAmountOwned
	local infoNonWeaponDesc = infoFrame.NonWeaponDescription
	local infoWeaponDesc = infoFrame.WeaponDescription
	local infoWeaponDescButton = infoFrame["WeaponDescriptionButton(HoverClickSoundSizeChange)"]
	local infoMastery = infoFrame.ItemMastery
	local baseStatsFrame = infoFrame.BaseStats

	local equipIcon = infoFrame["Equip(HoverSoundSizeChange)"]
	local baseStatsButton = infoFrame["BaseStatsButton(HoverClickSoundSizeChange)"]

	local clickSound = ReplicatedStorage.Assets.Shared.Sounds.MenuSounds.Click
	local hoverSound = ReplicatedStorage.Assets.Shared.Sounds.MenuSounds.Hover

	local AbilityData = require(ReplicatedStorage.Modules.Data.AbilityData)
	local abilitiesFrame = infoFrame.Abilties

	local IconSelected = nil
	local PrevIconSelected = nil
	local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	infoFrame.Visible = false

	infoRarity.Changed:Connect(function()
		infoFrame.Parent.BackgroundColor3 = infoRarity.TextColor3
	end)
	---Hover Size Increase---
	local function SizeIncrease(scale)
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, { Scale = 1.05 }):Play()
	end
	---Hover Size Decrease---
	local function SizeDecrease(scale)
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, { Scale = 1 }):Play()
	end

	for _,icon in Frame:GetChildren() do
		if icon:IsA("Frame") then
			icon:Destroy()
		end
	end


	NetworkingService:OnClientEvent("UpdateInventory", function(inventory)
		for  itemID, item in pairs(inventory) do

			for _,icon in Frame:GetChildren() do
				if icon:IsA("Frame") then
					if not inventory[itemID] then
						icon:Destroy()
					end
				end
			end

			local itemData = ItemDataBase:GetItemData(itemID)

			---Adding And Getting Icon---
			local iconFrame = Frame:FindFirstChild(item.Name)
			local icon = nil
			if iconFrame then
				icon = iconFrame:FindFirstChild(item.Name)
			end

			if not iconFrame then
				iconFrame = icons:WaitForChild(item.Rarity.."ItemFrame"):Clone()
				iconFrame.Name = item.Name
				iconFrame.Parent = Frame
				icon = iconFrame[item.Rarity.."Item"]
				icon.Name = iconFrame.Name

				local scale = icon:FindFirstChildWhichIsA("UIScale")
				if not scale then
					scale = Instance.new("UIScale")
					scale.Parent = icon
				end

				for _, Grad in icon:GetDescendants() do
					if Grad:IsA("UIGradient") then
						if string.find(Grad.Name, "RotGrad") then
							local info = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
							TweenService:Create(Grad, info, { Rotation = 405 }):Play()
						end
					end
				end

				iconFrame.MouseEnter:Connect(function()
					hoverSound:Play()
					icon.ImageColor3 = Color3.fromHex("#eeeeee")
					SizeIncrease(scale)
					if IconSelected ~= icon then
						TweenService:Create(icon.Border, info, { ImageColor3 = Color3.fromRGB(71, 88, 158) }):Play()
					end
				end)

				iconFrame.MouseLeave:Connect(function()
					icon.ImageColor3 = Color3.fromHex("#ffffff")
					SizeDecrease(scale)
					if IconSelected ~= icon then
						TweenService:Create(icon.Border, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					end
				end)

				icon.MouseButton1Down:Connect(function()
					SizeDecrease(scale)
				end)
				icon.MouseButton1Up:Connect(function()
					SizeIncrease(scale)
				end)

				icon.MouseButton1Click:Connect(function()
					PrevIconSelected = IconSelected
					IconSelected = icon
					if IconSelected ~= nil then
						TweenService
							:Create(IconSelected.Border, info, { ImageColor3 = Color3.fromRGB(114, 142, 255) })
							:Play()

						if PrevIconSelected ~= nil then
							if PrevIconSelected ~= IconSelected then
								TweenService
									:Create(
										PrevIconSelected.Border,
										info,
										{ ImageColor3 = Color3.fromRGB(255, 255, 255) }
									)
									:Play()
							end
						end
					end

					---ClickSound---
					clickSound:Play()

					---AbilityFrame---
					for _, ability in abilitiesFrame:GetChildren() do
						if ability:IsA("Frame") then
							local abilityLetter = ability.AbilityIcon.AbilityLetter.Text
							local abilityData = AbilityData.getAbilityData(item.Name .. abilityLetter)
							if not abilityData then
								ability.Visible = false
							else
								ability.Visible = true
								ability.AbilityMastery.Text = abilityData.AbilityMastery
								ability.AbilityName.Text = abilityData.AbilityName
							end
						end
					end

					---Icon Setup---
					infoFrame:SetAttribute("ItemName", item.Name)
					infoFrame:SetAttribute("ItemID", itemID)
					baseStatsFrame.Visible = false
					infoImage.Image = item.Icon
					infoText.Text = item.Name
					infoType.Text = item.Type
					infoRarity.Text = item.Rarity
					infoAmountOwned.Text = "Owned: " .. item.Amount
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
						infoWeaponDesc.Text = item.Description

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
						infoNonWeaponDesc.Text = item.Description
					else

						---If Item Is A Material---
						infoWeaponDesc.Visible = false
						infoWeaponDescButton.Visible = false
						infoNonWeaponDesc.Visible = true
						baseStatsButton.Visible = false
						equipIcon.Visible = false
						infoMastery.Visible = false
						infoNonWeaponDesc.Text = item.Description
					end
				end)
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

			iconFrame.Visible = true

			iconFrame:SetAttribute("IconEquipState", false)
			icon.EquippedIcon.Visible = false
		end
	end)

end