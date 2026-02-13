return function(button)
	local tween = game:GetService("TweenService")

	local abiltiesUI = button.Parent.Abilties
	local weaponDesc = button.Parent.WeaponDescription
	local baseStatsFrame = button.Parent.BaseStats

	local function SlideIn()
		local tween2 = tween:Create(weaponDesc, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.fromScale(0.043,0.428)}):Play()
		local tween3 = tween:Create(abiltiesUI, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.fromScale(1, 0.428)}):Play()
		wait(0.5)
		abiltiesUI.Position = UDim2.fromScale(-1,0.428)
	end
	local function SlideOut()
		local tween2 = tween:Create(weaponDesc, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.fromScale(1, 0.428)}):Play()
		local tween3 = tween:Create(abiltiesUI, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.fromScale(0.043,0.428)}):Play()
		wait(0.5)
		weaponDesc.Position = UDim2.fromScale(-1, 0.428)
	end

	button.MouseButton1Click:Connect(function()
		abiltiesUI.Visible = true
		baseStatsFrame.Visible = false
		if weaponDesc.Position.X.Scale == -1 then
			SlideIn()
		elseif abiltiesUI.Position.X.Scale == -1 then
			SlideOut()
		end


	end)
end