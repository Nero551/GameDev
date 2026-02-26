return function(resetButton ,statsMenu)
	local player  = game:GetService("Players").LocalPlayer
	local repstor = game:GetService("ReplicatedStorage")
	local tween = game:GetService("TweenService")
	local remotes = repstor.Remotes

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	local cloneConfirmPopup = require(script.Parent.Parent.CloneConfirmPopup)
	
	local confirmPopUp
	local confirmConnection

	local function GetConfirmPopup()
		if confirmPopUp and confirmPopUp.Parent then
			return confirmPopUp
		end

		confirmPopUp = cloneConfirmPopup()

		confirmPopUp:GetPropertyChangedSignal("Visible"):Connect(function()
			if confirmPopUp.Visible then
				tween:Create(resetButton.ResetText, info, {TextColor3 = Color3.fromRGB(255,154,213)}):Play()
				tween:Create(resetButton.RGBStroke, info, {ImageColor3 = Color3.fromRGB(255,154,213)}):Play()
				tween:Create(resetButton, info, {ImageColor3 = Color3.fromRGB(60,49,88)}):Play()
			else
				tween:Create(resetButton.ResetText, info, {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
				tween:Create(resetButton.RGBStroke, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
				tween:Create(resetButton, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
			end
		end)

		return confirmPopUp
	end

	remotes.UpdateEXP.OnClientEvent:Connect(function(playerLevel)
		statsMenu.StatPointsFrame.AvailablePoints.Text = "Points: "..playerLevel.StatPoints
	end)

	resetButton.MouseButton1Click:Connect(function()
		local popup = GetConfirmPopup()
		local confirmButton = popup["ConfirmButton(HoverClickSoundSizeChange)"]

		popup.TextLabel.Text = "Reset Stats?"
		popup.Visible = true
		tween:Create(popup, info, {Size = UDim2.fromScale(0.262, 0.49)}):Play()

		if confirmConnection then
			confirmConnection:Disconnect()
		end

		confirmConnection = confirmButton.MouseButton1Click:Connect(function()
			remotes.ResetStatPoints:FireServer()
			popup.Visible = false
		end)
	end)

	resetButton.MouseEnter:Connect(function()
		if confirmPopUp and not confirmPopUp.Visible then
			tween:Create(resetButton, info, {ImageColor3 = Color3.fromRGB(87,107,194)}):Play()
		end
	end)

	resetButton.MouseLeave:Connect(function()
		if confirmPopUp and not confirmPopUp.Visible then
			tween:Create(resetButton, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
		end
	end)

end