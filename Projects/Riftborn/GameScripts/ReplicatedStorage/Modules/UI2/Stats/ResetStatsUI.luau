local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
return function(resetButton ,statsMenu)
	local Player  = game:GetService("Players").LocalPlayer
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")
	local remotes = ReplicatedStorage.Remotes

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	local CloneConfirmPopupUI = require(game.ReplicatedStorage.Modules.UI2.CloneConfirmPopupUI)
	
	local confirmPopUp
	local confirmConnection

	local function GetConfirmPopup()
		if confirmPopUp and confirmPopUp.Parent then
			return confirmPopUp
		end

		confirmPopUp = CloneConfirmPopupUI()

		confirmPopUp:GetPropertyChangedSignal("Visible"):Connect(function()
			if confirmPopUp.Visible then
				TweenService:Create(resetButton.ResetText, info, {TextColor3 = Color3.fromRGB(255,154,213)}):Play()
				TweenService:Create(resetButton.RGBStroke, info, {ImageColor3 = Color3.fromRGB(255,154,213)}):Play()
				TweenService:Create(resetButton, info, {ImageColor3 = Color3.fromRGB(60,49,88)}):Play()
			else
				TweenService:Create(resetButton.ResetText, info, {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
				TweenService:Create(resetButton.RGBStroke, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
				TweenService:Create(resetButton, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
			end
		end)

		return confirmPopUp
	end

	NetworkingService:OnClientEvent("UpdateEXP", function(playerLevel)
		statsMenu.StatPointsFrame.AvailablePoints.Text = "Points: "..playerLevel.StatPoints
	end)

	resetButton.MouseButton1Click:Connect(function()
		local popup = GetConfirmPopup()
		local confirmButton = popup["ConfirmButton(HoverClickSoundSizeChange)"]

		popup.TextLabel.Text = "Reset Stats?"
		popup.Visible = true
		TweenService:Create(popup, info, {Size = UDim2.fromScale(0.262, 0.49)}):Play()

		if confirmConnection then
			confirmConnection:Disconnect()
		end

		confirmConnection = confirmButton.MouseButton1Click:Connect(function()
			NetworkingService:FireToServer("ResetStatPoints")
			popup.Visible = false
		end)
	end)

	resetButton.MouseEnter:Connect(function()
		if confirmPopUp and not confirmPopUp.Visible then
			TweenService:Create(resetButton, info, {ImageColor3 = Color3.fromRGB(87,107,194)}):Play()
		end
	end)

	resetButton.MouseLeave:Connect(function()
		if confirmPopUp and not confirmPopUp.Visible then
			TweenService:Create(resetButton, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
		end
	end)

end
