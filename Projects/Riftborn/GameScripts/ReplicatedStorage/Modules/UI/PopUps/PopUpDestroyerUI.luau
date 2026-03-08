return function()
	local TweenService = game:GetService("TweenService")
	local Player = game:GetService("Players").LocalPlayer
	local popupsFrame = Player:WaitForChild("PlayerGui"):WaitForChild("PopUpGui"):WaitForChild("PopUpsFrame")

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	for _,popup in popupsFrame:GetChildren() do
		if popup:IsA("Frame") then
			popup:Destroy()
		end
	end


	popupsFrame.ChildAdded:Connect(function()
		for _,popup in popupsFrame:GetChildren() do
			if popup:IsA("Frame") then
				task.wait(2)
				local tween = TweenService:Create(popup, info, {Size = UDim2.fromScale(0.3, 0.046)})
				tween:Play()
				tween.Completed:Connect(function()
					popup:Destroy()
				end)
				task.wait(2)
			end
		end
	end)

end