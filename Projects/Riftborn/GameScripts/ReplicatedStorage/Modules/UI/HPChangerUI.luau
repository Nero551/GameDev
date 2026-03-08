return function(hpBG, char:Model?)
	local TweenService = game:GetService("TweenService")
	local humanoid:Humanoid = char:WaitForChild("Humanoid")
	local hpBar = hpBG.HealthFill
	local hpText = hpBG.HealthNumber

	local function HpChanger(currentHealth, maxHealth)
		local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(hpBar, info , {Size = UDim2.fromScale(currentHealth/maxHealth,1)}):Play()
		hpText.Text = math.round(currentHealth).."/"..math.round(maxHealth)
	end

	local function ThirtyPercentHp(currentHealth, maxHealth)
		local info =  TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		if maxHealth / 3 > currentHealth then
			TweenService:Create(hpText, info, {TextColor3 = Color3.fromRGB(255, 140, 150)}):Play()
			TweenService:Create(hpBG.HealthText, info, {TextColor3 = Color3.fromRGB(255, 140, 150)}):Play()

		else
			TweenService:Create(hpText, info, {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			TweenService:Create(hpBG.HealthText, info, {TextColor3 = Color3.fromRGB(255, 255,255)}):Play()
		end
	end
	
	local function UpdateHealthUI()
		local currentHealth = char:GetAttribute("Health_CurrentHealth")
		local maxHealth = char:GetAttribute("Health_MaxHealth")
		if currentHealth and maxHealth then
			
			HpChanger(currentHealth, maxHealth)
			ThirtyPercentHp(currentHealth, maxHealth)
		end
	end
	
	UpdateHealthUI()
	
	char:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(UpdateHealthUI)
	char:GetAttributeChangedSignal("Health_MaxHealth"):Connect(UpdateHealthUI)

end