return function(hpBG)
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local tween = game:GetService("TweenService")
	local humanoid:Humanoid = char:WaitForChild("Humanoid")
	local hpBar = hpBG.HealthFill
	local hpText = hpBG.HealthNumber

	local function HpChanger()
		local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		tween:Create(hpBar, info , {Size = UDim2.fromScale(humanoid.Health/humanoid.MaxHealth,1)}):Play()
		hpText.Text = math.round(humanoid.Health).."/"..math.round(humanoid.MaxHealth)
	end

	HpChanger()

	local function ThirtyPercentHp()
		local info =  TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		if humanoid.MaxHealth / 3 > humanoid.Health then
			tween:Create(hpText, info, {TextColor3 = Color3.fromRGB(255, 140, 150)}):Play()
			tween:Create(hpBG.HealthText, info, {TextColor3 = Color3.fromRGB(255, 140, 150)}):Play()

		else
			tween:Create(hpText, info, {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			tween:Create(hpBG.HealthText, info, {TextColor3 = Color3.fromRGB(255, 255,255)}):Play()
		end
	end

	humanoid.HealthChanged:Connect(function()
		HpChanger()
		ThirtyPercentHp()
	end)
end