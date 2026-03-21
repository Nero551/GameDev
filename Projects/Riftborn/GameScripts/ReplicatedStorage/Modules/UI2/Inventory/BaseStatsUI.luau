return function  (infoFrame)
	local TweenService = game:GetService("TweenService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)

	local baseStatsbutton = infoFrame:FindFirstChild("BaseStatsButton(HoverClickSoundSizeChange)")
	local baseStatsFrame = infoFrame:FindFirstChild("BaseStats")
	local infoName = infoFrame:FindFirstChild("ItemNameValue")

	local statsScrollingFrame = baseStatsFrame.ScrollingFrame
	local abiltiesFrame = infoFrame.Abilties

	local weaponDesc =  infoFrame.WeaponDescription
	local nonWeaponDesc = infoFrame.NonWeaponDescription


	local info = TweenInfo.new(0.125,Enum.EasingStyle.Quad, Enum.EasingDirection.Out)


	baseStatsFrame.Changed:Connect(function()
		if baseStatsFrame.Visible ==  true then
			abiltiesFrame.Visible = false
			weaponDesc.Visible = false
			nonWeaponDesc.Visible = false
			TweenService:Create(baseStatsbutton, info , {ImageColor3 = Color3.fromRGB(26, 21, 38)}):Play()
			TweenService:Create(baseStatsbutton.BaseStats, info , {TextColor3 = Color3.fromRGB(255, 154, 213)}):Play()
			TweenService:Create(baseStatsbutton.RGBStroke, info , {ImageColor3 = Color3.fromRGB(255, 154, 213)}):Play()
		else
			TweenService:Create(baseStatsbutton, info , {ImageColor3  = Color3.fromRGB(255,255,255)}):Play()
			TweenService:Create(baseStatsbutton.BaseStats, info , {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			TweenService:Create(baseStatsbutton.RGBStroke, info , {ImageColor3 =  Color3.fromRGB(255,255,255)}):Play()

			if infoFrame.ItemType.Text == "Sword" or infoFrame.ItemType.Text ==  "Melee" then
				weaponDesc.Visible = true
				abiltiesFrame.Visible = true
				nonWeaponDesc.Visible = false
			else
				abiltiesFrame.Visible = false
				weaponDesc.Visible = false
				nonWeaponDesc.Visible = true
			end

		end
	end)

	infoName.Changed:Connect(function()
		baseStatsFrame.Visible = false
	end)


	baseStatsbutton.MouseEnter:Connect(function()
		if baseStatsFrame.Visible == false  then
			TweenService:Create(baseStatsbutton, info , {ImageColor3 = Color3.fromRGB(87, 107, 194)}):Play()
		end
	end)

	baseStatsbutton.MouseLeave:Connect(function()
		if baseStatsFrame.Visible == false then
			TweenService:Create(baseStatsbutton, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
		end
	end)

	baseStatsbutton.MouseButton1Click:Connect(function()
		local infoID = infoFrame:GetAttribute("ItemID")
		local infoType = infoFrame:GetAttribute("IconType")

		if infoType == "Sword" or infoType == "Melee" then
			infoType = "Weapon"
		elseif infoType ==  "Helmet" or infoType == "ChestPlate" or infoType == "Leggings" or infoType == "Boots" then
			infoType = "Armor"
		end

		local itemData = ItemDataBase:GetItemData(infoID)
		for _,Stat in statsScrollingFrame:GetChildren() do
			if Stat:IsA("Frame") then
				local statCatagory:TextLabel = Stat.StatCatagory.Text
				local statNumber:TextLabel = Stat.StatNumber
				if itemData[statCatagory] == nil then
					if itemData.Buffs then
						if itemData.Buffs[statCatagory] == nil then
							Stat.Visible = false
							statNumber.Text = ""
						else	
							Stat.Visible = true
							if itemData.Buffs[statCatagory].Percent then
								statNumber.Text = "+"..(itemData.Buffs[statCatagory].Percent*100).."%"
							else
								statNumber.Text = "+"..itemData.Buffs[statCatagory].Flat
							end
						end	
					else
						Stat.Visible = false
						statNumber.Text = ""
					end	
				else
					Stat.Visible = true
					if Stat.Name  == "CriticalRate"  or Stat.Name == "CriticalDamage" then
						statNumber.Text = ( itemData[statCatagory] *100 ) .."%"
					else
						statNumber.Text = itemData[statCatagory]
					end						
				end


			end
		end
		if baseStatsFrame.Visible == true then
			baseStatsFrame.Visible = false
		else
			baseStatsFrame.Visible = true
		end
	end)
end
