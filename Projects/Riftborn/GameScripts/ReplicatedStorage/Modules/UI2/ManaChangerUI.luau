return function(manaBG, char:Model?)
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local humanoid:Humanoid = char:WaitForChild("Humanoid")
	local ManaBar = manaBG.ManaFill
	local ManaText = manaBG.ManaNumber

	local function ManaChangerUI(MaxMana, CurrentMana)
		local info = TweenInfo.new(0.04, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
		TweenService:Create(ManaBar, info , {Size = UDim2.fromScale(CurrentMana/MaxMana,1)}):Play()
		ManaText.Text = math.round(CurrentMana).."/"..math.round(MaxMana)
	end	
	
	local function UpdateManaUI()
		local currentMana = char:GetAttribute("Mana_CurrentMana")
		local maxMana = char:GetAttribute("Mana_MaxMana")
		if currentMana and maxMana then


			ManaChangerUI(maxMana, currentMana)
		end
	end

	char:GetAttributeChangedSignal("Mana_CurrentMana"):Connect(UpdateManaUI)
	char:GetAttributeChangedSignal("Mana_MaxMana"):Connect(UpdateManaUI)

	-- Initialize once
	UpdateManaUI()

end