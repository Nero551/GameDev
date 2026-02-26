return function()
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local tweenService = game:GetService("TweenService")
	
	local startScreen = player:WaitForChild("PlayerGui"):WaitForChild("StartScreen")

	--startScreen.Enabled = true


	---Music---
	local bgMusic = game.ReplicatedStorage.Assets.Shared.Sounds.Music.StartScreenBGMusic
	local info = TweenInfo.new(5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local clone
	clone = bgMusic:Clone()
	clone.Parent = hrp
	clone:Play()

	startScreen.Changed:Connect(function()
		if startScreen.Enabled == true then
			if not clone then
				clone = bgMusic:Clone()
				clone.Parent = hrp
				clone:Play()
			end
		else

			local tween = tweenService:Create(clone, info, {Volume = 0})
			tween:Play()
			tween.Completed:Connect(function()
				clone:Stop()
				clone:Destroy()
				clone = nil
			end)

		end
	end)
end