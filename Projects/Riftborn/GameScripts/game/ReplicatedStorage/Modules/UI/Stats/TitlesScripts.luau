return function(titles, overviewFrameTitleText)
	local repstor = game:GetService("ReplicatedStorage")
	local tweenService = game:GetService("TweenService")	
	
	local function createGradientFromTable(colorTable)
		local keypoints = {}
		table.sort(colorTable, function(a,b) return a.Position < b.Position end)
		for _, color in ipairs(colorTable) do
			local r,g,b = color.Color:match("(%d+),%s*(%d+),%s*(%d+)")
			local c3 = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
			table.insert(keypoints, ColorSequenceKeypoint.new(color.Position, c3))
		end
		return ColorSequence.new(keypoints)
	end


	repstor.Remotes.UpdateTitles.OnClientEvent:Connect(function(playerTitle)
		for _,title in titles:GetChildren() do
			if title:IsA("ImageButton") then
				title:Destroy()
			end
		end


		---Frame---
		for titleID,title in pairs(playerTitle.Titles) do
			local titleImgButton:ImageButton? = titles:FindFirstChild(titleID)
			if not titleImgButton then
				titleImgButton = repstor.Assets.GUI.Title:Clone()
				local titleName:TextLabel? = titleImgButton.TitleName
				local gradient:UIGradient = titleName.UIGradient
				titleImgButton.Parent = titles
				titleImgButton.Name = titleID
				titleName.Text = title.Name
				titleImgButton.TitleID.Value = titleID
				if title.Color then
					local keypoints = {}
					local count = #title.Color
					for _, color in ipairs(title.Color) do
						gradient.Color = createGradientFromTable(title.Color)

					end

				else
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),	
						ColorSequenceKeypoint.new(1, Color3.fromRGB(154, 154, 154))	
					})
				end
				local tweenInfo = TweenInfo.new(16, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1 , true)
				tweenService:Create(gradient, tweenInfo, {Rotation = 360}):Play()


				---Stats---
				for stat,buff in pairs(title.Buffs) do
					if buff.Percent then
						local buffText = titleImgButton.TitleBuffs:FindFirstChild(stat.."Percent")
						if not buffText then
							buffText = titleImgButton.TitleBuffs.Template:Clone()
							buffText.Name = stat..buff.Percent
							buffText.Visible = true
							buffText.Parent = titleImgButton.TitleBuffs
							buffText.Text = "+"..(buff.Percent*100).."% "..stat
						end
					end	
					if buff.Flat then
						local buffText = titleImgButton.TitleBuffs:FindFirstChild(stat.."Flat")
						if not buffText then
							buffText = titleImgButton.TitleBuffs.Template:Clone()
							buffText.Name = stat..buff.Flat
							buffText.Visible = true
							buffText.Parent = titleImgButton.TitleBuffs
							buffText.Text = "+"..buff.Flat.." "..stat
						end		
					end
				end
			end


			---Equip Button(Some of the Modifications)---
			local equipButton = titleImgButton["Equip(HoverSoundSizeChange)"]["EquipButton(ClickSoundSizeChange)"]
			local unequipButton = titleImgButton["Equip(HoverSoundSizeChange)"]["UnEquipButton(ClickSoundSizeChange)"]
			if playerTitle.ActiveTitle == titleID then		
				equipButton.Visible = false
				unequipButton.Visible = true
			else			
				equipButton.Visible = true
				unequipButton.Visible = false			
			end
		end

		---Title in Overview Menu---
		if playerTitle.ActiveTitle == nil then
			overviewFrameTitleText.Visible = false

		else
			local title = playerTitle.Titles[playerTitle.ActiveTitle]
			overviewFrameTitleText.Visible = true
			overviewFrameTitleText.Text = title.Name

			if title.Color then
				overviewFrameTitleText.UIGradient.Color = createGradientFromTable(title.Color)

			else
				overviewFrameTitleText.UIGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),	
					ColorSequenceKeypoint.new(1, Color3.fromRGB(154, 154, 154))
				})
			end
			local tweenInfo = TweenInfo.new(16, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1 , true)
			tweenService:Create(overviewFrameTitleText.UIGradient, tweenInfo, {Rotation = 360}):Play()
		end
	end)

end