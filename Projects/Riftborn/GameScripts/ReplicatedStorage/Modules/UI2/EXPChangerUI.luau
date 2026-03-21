local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.Core.NetworkingService)
return function(expBG, levelFrame)
	local TweenService = game:GetService("TweenService")
	local EXPFill = expBG.EXPFill
	local EXPNumber = expBG.EXPNumber


	NetworkingService:OnClientEvent("UpdateEXP", function(playerLevel)
		local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local ratio = playerLevel.CurrentEXP / playerLevel.RequiredEXP
		ratio = math.clamp(ratio, 0, 1)


		TweenService:Create(EXPFill, info , {Size = UDim2.fromScale(ratio,1)}):Play()
		EXPNumber.Text = math.round(playerLevel.CurrentEXP).." / "..math.round(playerLevel.RequiredEXP)
		levelFrame.LevelNumber.Text = playerLevel.CurrentLevel

	end)
end
