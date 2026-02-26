return function(Menu , returnButton, mainmenu)
	local tweenService = game:GetService("TweenService")


	local function OpenMainMenu()
		mainmenu.Visible = true
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		tweenService:Create(mainmenu, info, {Size = UDim2.fromScale(0.4, 0.9)}):Play()
	end


	local function CloseMenu()
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		tweenService:Create(Menu, info, {Size = UDim2.fromScale(0, 0)}):Play()
	end

	returnButton.MouseButton1Click:Connect(function()
		CloseMenu()
		OpenMainMenu()
	end)
end