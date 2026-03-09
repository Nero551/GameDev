return function(button)

local TweenService = game:GetService("TweenService")
	local MenuGUI = button.Parent.Parent.Parent.Parent:WaitForChild("MenusGUI")
	local MainMenu = MenuGUI.MainMenu
	local texture = MenuGUI.Texture
	local gradient = button.UIGradient
	local Lighting = game:GetService("Lighting")
	local blur = Lighting.Blur

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)


	button.Parent.MouseEnter:Connect(function()
		TweenService:Create(button.Parent, info, {ImageColor3 = Color3.fromRGB(87, 107, 194)}):Play()
	end)

	button.Parent.MouseLeave:Connect(function()
		TweenService:Create(button.Parent, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
	end)


	local function BackgroundBlurTweenIn()
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(blur, info, {Size = 24}):Play()
		TweenService:Create(texture, info, {ImageTransparency = 0.8}):Play()
	end

	local function BackgroundBlurTweenOut()
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(blur, info, {Size = 0}):Play()
		TweenService:Create(texture, info, {ImageTransparency = 1}):Play()
	end



	local function OpenMenu()
		MainMenu.Visible =  true
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		TweenService:Create(MainMenu, info, {Size = UDim2.fromScale(0.4, 0.9)}):Play()
	end

	local function CloseMenu()
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		TweenService:Create(MainMenu, info, {Size = UDim2.fromScale(0,0)}):Play()
		MainMenu.Visible = false
	end


	button.MouseButton1Click:Connect(function()
		if MainMenu.Size ==  UDim2.fromScale(0,0) then
			OpenMenu()
			BackgroundBlurTweenIn()
		elseif MainMenu.Size == UDim2.fromScale(0.4, 0.9) then
			CloseMenu()
			BackgroundBlurTweenOut()
		end
	end)

end