return function(manaBG)
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local tween = game:GetService("TweenService")
	local runService = game:GetService("RunService")
	local humanoid:Humanoid = char:WaitForChild("Humanoid")
	local  playerMana = player:WaitForChild("PlayerMana")
	local ManaBar = manaBG.ManaFill
	local ManaText = manaBG.ManaNumber



	local function ManaChanger()
		local MaxMana = playerMana.MaxMana.Value
		local CurrentMana = playerMana.CurrentMana.Value
		local info = TweenInfo.new(0.04, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
		tween:Create(ManaBar, info , {Size = UDim2.fromScale(CurrentMana/MaxMana,1)}):Play()
		ManaText.Text = math.round(CurrentMana).."/"..math.round(MaxMana)
	end

	ManaChanger()
	playerMana.CurrentMana.Changed:Connect(function()
		ManaChanger()
	end)
	playerMana.MaxMana.Changed:Connect(function()
		ManaChanger()
	end)
end