return function()
	local tweenService = game:GetService("TweenService")
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local player = game:GetService("Players").LocalPlayer
	local startScreen = player:WaitForChild("PlayerGui"):WaitForChild("StartScreen")
	local charCustomizationButton = startScreen.StartMenu.Options["CharCustomizationButton(HoverClickSoundSizeChange)"]

	charCustomizationButton.MouseButton1Click:Connect(function()
	end)

	charCustomizationButton.MouseEnter:Connect(function()
		tweenService:Create(charCustomizationButton.Text, info , {TextColor3 = Color3.fromRGB(255, 154, 213)}):Play()
		tweenService:Create(charCustomizationButton.RGBStroke, info , {ImageColor3 = Color3.fromRGB(255, 154, 213)}):Play()
		tweenService:Create(charCustomizationButton, info , {ImageColor3 = Color3.fromRGB(26, 21, 38)}):Play()
	end)

	charCustomizationButton.MouseLeave:Connect(function()
		tweenService:Create(charCustomizationButton.Text, info , {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
		tweenService:Create(charCustomizationButton.RGBStroke, info , {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
		tweenService:Create(charCustomizationButton, info , {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
	end)
end