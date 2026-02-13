return function  (scrollingFrame, infoFrame)
	local repstor = game:GetService("ReplicatedStorage")
	local tweenService = game:GetService("TweenService")
	local remotes = repstor.Remotes
	local updateInventory  = remotes.UpdateInventory

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
	local equipButton = equipIcon["UnEquipButton(ClickSoundSizeChange)"]
	local unequipButton = equipIcon["UnEquipButton(ClickSoundSizeChange)"]
	local baseStatsButton = infoFrame["BaseStatsButton(HoverClickSoundSizeChange)"] 

	local clickSound = repstor.Assets.Shared.Sounds.MenuSounds.Click
	local hoverSound = repstor.Assets.Shared.Sounds.MenuSounds.Hover

	local abilityModule = require(repstor.Modules.Data.AbilityData)
	local abilitiesFrame = infoFrame.Abilties

	local  IconSelected = nil
	local PrevIconSelected = nil

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	infoFrame.Visible = false

	infoRarity.Changed:Connect(function()
		infoFrame.Parent.BackgroundColor3 = infoRarity.TextColor3
	end)


	remotes.UpdateInventoryInfo.OnClientEvent:Connect(function(inventory , equippedItems)
		for _,iconFrame:Frame? in  scrollingFrame:GetChildren() do
			if iconFrame:IsA("Frame") then
				local icon:ImageButton? = iconFrame:FindFirstChildWhichIsA("ImageButton")
				local scale = icon:FindFirstChildWhichIsA("UIScale")
				if not scale then
					scale = Instance.new("UIScale")
					scale.Parent = icon
				end

				for _,Grad:UIGradient? in icon:GetDescendants() do
					if Grad:IsA("UIGradient") then
						if string.find(Grad.Name , "RotGrad") then
							local info = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut , -1, true)
							tweenService:Create(Grad, info, {Rotation = 405}):Play()
						end
					end
				end
				---Hover Size Increase---
				local function SizeIncrease()
					local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					tweenService:Create(scale , info , {Scale = 1.05}):Play()
				end
				---Hover Size Decrease---
				local function SizeDecrease()
					local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					tweenService:Create(scale , info , {Scale = 1}):Play()
				end
				---ClickSize Decrease---
				local function SizeClickDecrease()
					local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					tweenService:Create(scale, info, {Scale = 0.975}):Play()
				end

				local iconEquipped:ImageLabel = icon.EquippedIcon
				local iconImage:ImageLabel = icon.Icon
				local iconName:StringValue = icon.Name
				local iconType:StringValue = icon.IconType
				local iconDesc:StringValue = icon.IconDescription
				local iconRarity:StringValue = icon.IconRarity
				local iconAmountOwned:TextLabel = icon.OwnedAmount
				local iconItemId:StringValue? = icon.ItemID

				iconFrame.MouseEnter:Connect(function()
					hoverSound:Play()
					icon.ImageColor3 = Color3.fromHex("#eeeeee")
					SizeIncrease()
					if IconSelected ~= icon then
						tweenService:Create(icon.Border, info, {ImageColor3 = Color3.fromRGB(71,88,158)}):Play()
					end
				end)

				iconFrame.MouseLeave:Connect(function()
					icon.ImageColor3 = Color3.fromHex("#ffffff")
					SizeDecrease()
					if IconSelected ~= icon then
						tweenService:Create(icon.Border, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
					end
				end)

				icon.MouseButton1Down:Connect(function()
					SizeDecrease()
				end)
				icon.MouseButton1Up:Connect(function()
					SizeIncrease()
				end)

				icon.MouseButton1Click:Connect(function()
					if iconType.Value == "" then return end

					PrevIconSelected = IconSelected
					IconSelected = icon
					if  IconSelected ~= nil then
						tweenService:Create(IconSelected.Border, info, {ImageColor3 = Color3.fromRGB(114, 142,255)}):Play()

						if PrevIconSelected ~= nil  then
							if PrevIconSelected ~= IconSelected then
								tweenService:Create(PrevIconSelected.Border, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
							end
						end
					end

					---ClickSound---
					clickSound:Play()

					---AbilityFrame---
					for _, ability in abilitiesFrame:GetChildren() do
						if ability:IsA("Frame") then
							local abilityLetter = ability.AbilityIcon.AbilityLetter.Text
							local abilityData =  abilityModule.getAbilityData(iconName..abilityLetter)
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
					infoFrame.ItemNameValue.Value = iconName
					infoFrame.ItemID.Value = iconItemId.Value
					baseStatsFrame.Visible = false
					infoImage.Image = iconImage.Image
					infoText.Text = iconName
					infoType.Text = iconType.Value
					infoRarity.Text = iconRarity.Value
					infoAmountOwned.Text = "Owned: "..iconAmountOwned.Text
					infoFrame.Visible = true


					---If Item Is A Weapon---
					if infoType.Text == "Sword" or infoType.Text == "Melee" then
						abilitiesFrame.Position = UDim2.fromScale(0.043, 0.428)
						infoWeaponDesc.Position = UDim2.fromScale(-1 , 0.428)
						baseStatsButton.Visible = true
						abilitiesFrame.Visible = true
						equipIcon.Visible = true
						infoNonWeaponDesc.Visible = false
						infoWeaponDescButton.Visible = true
						infoWeaponDesc.Visible = true
						infoMastery.Visible = true
						infoWeaponDesc.Text = iconDesc.Value

						---If Item Is An Armor
					elseif infoType.Text == "Helmet" or infoType.Text == "ChestPlate" or infoType.Text == "Leggings" or infoType.Text == "Boots" then
						infoWeaponDesc.Visible = false
						infoWeaponDescButton.Visible = false
						infoNonWeaponDesc.Visible = true
						baseStatsButton.Visible  = true
						equipIcon.Visible = true
						infoMastery.Visible = false
						infoNonWeaponDesc.Text = iconDesc.Value
					else

						---If Item Is A Material---
						infoWeaponDesc.Visible = false
						infoWeaponDescButton.Visible = false
						infoNonWeaponDesc.Visible = true
						baseStatsButton.Visible  = false
						equipIcon.Visible = false
						infoMastery.Visible = false
						infoNonWeaponDesc.Text = iconDesc.Value
					end
				end)
			end
		end	
	end)

end