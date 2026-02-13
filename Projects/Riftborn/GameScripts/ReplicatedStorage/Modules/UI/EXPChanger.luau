return function(expBG)
	local repstor = game:GetService("ReplicatedStorage")
	local tweenService = game:GetService("TweenService")
	local remotes = repstor.Remotes
	local EXPFill = expBG.EXPFill
	local EXPNumber = expBG.EXPNumber


	remotes.UpdateEXP.OnClientEvent:Connect(function(playerLevel)
		local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local ratio = playerLevel.CurrentEXP / playerLevel.RequiredEXP
		ratio = math.clamp(ratio, 0, 1)


		tweenService:Create(EXPFill, info , {Size = UDim2.fromScale(ratio,1)}):Play()
		EXPNumber.Text = math.round(playerLevel.CurrentEXP).." / "..math.round(playerLevel.RequiredEXP)
		expBG.Parent.Parent.Parent.Level.LevelNumber.Text = playerLevel.CurrentLevel

	end)
end