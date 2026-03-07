local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
return function(trackQuestbutton)
	local tweenService = game:GetService("TweenService")

	------------------------------------------------------------------------------------------------------------------------------

trackQuestbutton.MouseButton1Click:Connect(function()
		local questName = trackQuestbutton.Parent.TrackedQuestName.Text
		NetworkingService:FireToServer("TrackQuest", questName)


	end)

	------------------------------------------------------------------------------------------------------------------------------

	---Looks BS---
	local function SizeIncrease(scale:UIScale)
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		tweenService:Create(scale, info, {Scale = 1.025}):Play()
	end

	local function SizeDecrease(scale:UIScale)
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		tweenService:Create(scale, info, {Scale = 1}):Play()
	end

	local function SizeClickDecrease(scale:UIScale)
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		tweenService:Create(scale, info, {Scale = 0.975}):Play()
	end


	local scale = trackQuestbutton.UIScale

	trackQuestbutton.MouseEnter:Connect(function()
		SizeIncrease(scale)

	end)

	trackQuestbutton.MouseLeave:Connect(function()
		SizeDecrease(scale)

	end)

	trackQuestbutton.MouseButton1Down:Connect(function()
		SizeClickDecrease(scale)
	end)

	trackQuestbutton.MouseButton1Up:Connect(function()
		SizeIncrease(scale)
	end)
	------------------------------------------------------------------------------------------------------------------------------
end
