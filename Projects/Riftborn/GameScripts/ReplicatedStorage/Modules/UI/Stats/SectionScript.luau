return function(sectionButtons)
	local tweenService = game:GetService("TweenService")
	local StatsMenu = sectionButtons.Parent.Parent

	local isSliding = false

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function SlideIn(sectionMenu)
		if isSliding then return end
		isSliding = true
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local tween = tweenService:Create(sectionMenu, info, {Position = UDim2.fromScale(0.5, 0.558)})
		tween:Play()
		tween.Completed:Connect(function()
			isSliding = false
		end)
	end




	for _,sectionButton in sectionButtons:GetChildren() do
		if sectionButton:IsA("ImageButton") then
			local sectionNames = sectionButton.Name:split("(HoverClickSoundSizeChange)")[1]
			local sectionMenus = StatsMenu:FindFirstChild(sectionNames)

			sectionButton.MouseButton1Click:Connect(function()
				local sectionName = sectionButton.Name:split("(HoverClickSoundSizeChange)")[1]
				local sectionMenu = StatsMenu:FindFirstChild(sectionName)
				if not sectionMenu then return end
				for _,frame in StatsMenu:GetChildren() do
					if frame:IsA("Frame") then
						if frame.Name  ~= "TopBar" then
							if frame.Name ~= sectionName then
								frame.Visible = false
								frame.Position = UDim2.fromScale(-0.5,0.558)
							end
						end
					end
				end
				sectionMenu.Visible = true
				SlideIn(sectionMenu)

			end)	


			---Looks BS---
			local function SectionSelected()
				if sectionMenus.Position ~= UDim2.fromScale(-0.5, 0.558)  then
					tweenService:Create(sectionButton.SectionName, info , {TextColor3 = Color3.fromRGB(255, 154, 213)}):Play()
					tweenService:Create(sectionButton.RGBStroke, info , {ImageColor3 = Color3.fromRGB(255, 154, 213)}):Play()
					tweenService:Create(sectionButton, info , {ImageColor3 = Color3.fromRGB(60, 49, 88)}):Play()
					tweenService:Create(sectionButton.SectionName, info ,   {TextStrokeTransparency = 0 }):Play()

				else

					tweenService:Create(sectionButton.SectionName, info , {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
					tweenService:Create(sectionButton.RGBStroke, info , {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
					tweenService:Create(sectionButton, info , {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
					tweenService:Create(sectionButton.SectionName, info ,   {TextStrokeTransparency = 1 }):Play()

				end
			end
			SectionSelected()
			sectionMenus.Changed:Connect(function()
				SectionSelected()
			end)

			sectionButton.MouseEnter:Connect(function()
				if sectionMenus.Position == UDim2.fromScale(-0.5, 0.558)  then
					tweenService:Create(sectionButton, info, {ImageColor3 =  Color3.fromRGB(87, 107, 194)}):Play()
				end
			end)

			sectionButton.MouseLeave:Connect(function()
				if sectionMenus.Position == UDim2.fromScale(-0.5, 0.558) then
					tweenService:Create(sectionButton, info, {ImageColor3 =  Color3.fromRGB(255,255,255)}):Play()
				end
			end)
		end
	end
end