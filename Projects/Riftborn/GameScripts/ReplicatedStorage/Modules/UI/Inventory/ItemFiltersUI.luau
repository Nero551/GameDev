return function  (Icons, Filters)
	local tweenService = game:GetService("TweenService")

	local filterSelected = nil
	local prevFilterSelected = nil

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, filter in Filters:GetChildren() do
		if filter:IsA("ImageButton") then

			filter.MouseEnter:Connect(function()
				if filterSelected ~= filter then
					tweenService:Create(filter, info ,{ImageColor3 =  Color3.fromRGB(87, 107, 194)}):Play()
				end
			end)

			filter.MouseLeave:Connect(function()
				if filterSelected ~= filter then
					tweenService:Create(filter, info ,{ImageColor3 =  Color3.fromRGB(255,255,255)}):Play()
				end
			end)

			filter.MouseButton1Click:Connect(function()

				prevFilterSelected  = filterSelected
				filterSelected = filter

				if filterSelected ~= nil then
					tweenService:Create(filterSelected["FilterType"], info ,{TextColor3 =  Color3.fromRGB(255, 154, 213)}):Play()
					tweenService:Create(filterSelected.RGBStroke, info ,{ImageColor3 =  Color3.fromRGB(255, 154, 213)}):Play()
					tweenService:Create(filterSelected, info ,{ImageColor3 =  Color3.fromRGB(60, 49, 88)}):Play()
					if prevFilterSelected ~= nil then
						if prevFilterSelected ~= filterSelected then
							tweenService:Create(prevFilterSelected, info ,{ImageColor3 =  Color3.fromRGB(255,255,255)}):Play()
							tweenService:Create(prevFilterSelected.RGBStroke, info ,{ImageColor3 =  Color3.fromRGB(255, 255, 255)}):Play()
							tweenService:Create(prevFilterSelected["FilterType"], info ,{TextColor3 =  Color3.fromRGB(255, 255, 255)}):Play()
						end

					end
				end
				---Filter---
				local filterType = filter.FilterType.Text
				if filterType == "All" then
					for _, iconFrame in Icons:GetChildren() do
						if iconFrame:IsA("Frame") then
							iconFrame.Visible = true
						end
					end
				else
					for _, iconFrame in Icons:GetChildren() do
						if iconFrame:IsA("Frame") then
							iconFrame.Visible = true
						end
					end
					for _, iconFrame in Icons:GetChildren() do
						if iconFrame:IsA("Frame") then
							if iconFrame:GetAttribute("IconType") ~= filterType then	
								iconFrame.Visible = false
							end

							if iconFrame:GetAttribute("IconType") == "Helmet" or iconFrame:GetAttribute("IconType") == "ChestPlate" 
								or iconFrame:GetAttribute("IconType") == "Leggings" or iconFrame:GetAttribute("IconType") == "Boots" then
								local iconType = "Armor"
								if iconType == filterType then
									iconFrame.Visible = true
								end
							end
						end
					end
				end
			end)
		end	
	end

end