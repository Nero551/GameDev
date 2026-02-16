return function()
	local tweenService = game:GetService("TweenService")
	local player = game:GetService("Players").LocalPlayer
	local startScreen = player:WaitForChild("PlayerGui"):WaitForChild("StartScreen")
	
	local playButton = startScreen.StartMenu.Options["PlayButton(HoverClickSoundSizeChange)"]
	
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	playButton.MouseButton1Click:Connect(function()
		startScreen.Enabled = false
	end)

	playButton.MouseEnter:Connect(function()
		tweenService:Create(playButton.Text, info , {TextColor3 = Color3.fromRGB(255, 154, 213)}):Play()
		tweenService:Create(playButton.RGBStroke, info , {ImageColor3 = Color3.fromRGB(255, 154, 213)}):Play()
		tweenService:Create(playButton, info , {ImageColor3 = Color3.fromRGB(26, 21, 38)}):Play()
	end)

	playButton.MouseLeave:Connect(function()
		tweenService:Create(playButton.Text, info , {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
		tweenService:Create(playButton.RGBStroke, info , {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
		tweenService:Create(playButton, info , {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
	end)
end