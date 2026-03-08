return function(Filters, quests)
	local TweenService = game:GetService("TweenService")

	local Player = game:GetService("Players").LocalPlayer
	local char = Player.Character or Player.CharacterAdded:Wait()

	local filterSelected:ImageButton? = nil
	local prevFilterSelected:ImageButton? = nil

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)



	for _, filter:ImageButton? in Filters:GetChildren() do
		if filter:IsA("ImageButton") then

			---Looks BS---
			filter.MouseEnter:Connect(function()
				if filterSelected ~= filter then
					TweenService:Create(filter, info ,{ImageColor3 =  Color3.fromRGB(87, 107, 194)}):Play()
				end
			end)



			filter.MouseLeave:Connect(function()
				if filterSelected ~= filter then
					TweenService:Create(filter, info ,{ImageColor3 =  Color3.fromRGB(255,255,255)}):Play()
				end
			end)

			filter.MouseButton1Click:Connect(function()

				prevFilterSelected  = filterSelected
				filterSelected = filter

				if filterSelected ~= nil then
					TweenService:Create(filterSelected["FilterType"], info ,{TextColor3 =  Color3.fromRGB(255, 154, 213)}):Play()
					TweenService:Create(filterSelected.RGBStroke, info ,{ImageColor3 =  Color3.fromRGB(255, 154, 213)}):Play()
					TweenService:Create(filterSelected, info ,{ImageColor3 =  Color3.fromRGB(60, 49, 88)}):Play()
					if prevFilterSelected ~= nil then
						if prevFilterSelected ~= filterSelected then
							TweenService:Create(prevFilterSelected, info ,{ImageColor3 =  Color3.fromRGB(255,255,255)}):Play()
							TweenService:Create(prevFilterSelected.RGBStroke, info ,{ImageColor3 =  Color3.fromRGB(255, 255, 255)}):Play()
							TweenService:Create(prevFilterSelected["FilterType"], info ,{TextColor3 =  Color3.fromRGB(255, 255, 255)}):Play()
						end

					end
				end

				---Filter---
				local filterType = filter.FilterType.Text:gsub("s$","")
				if filterType == "All Quest" then
					for _, questFrame in quests:GetChildren() do
						if questFrame:IsA("ImageButton") then
							questFrame.Visible = true
						end
					end
				else
					for _, questFrame in quests:GetChildren() do
						if questFrame:IsA("ImageButton") then
							questFrame.Visible = true
						end
					end
					for _, questFrame in quests:GetChildren() do
						if questFrame:IsA("ImageButton") then
							local questType = questFrame.QuestType.Text
							if questType ~= filterType then	
								questFrame.Visible = false
							else
								questFrame.Visible = true

							end
						end
					end
				end
			end)
		end	
	end


end