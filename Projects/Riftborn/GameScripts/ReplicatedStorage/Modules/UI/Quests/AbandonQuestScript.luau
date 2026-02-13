return function(questMenu, abandonQuestButton)
	local repstor = game:GetService("ReplicatedStorage")
	local tweenService = game:GetService("TweenService")


	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local confirmPopup
	local confirmConnection

	local function GetConfirmPopup()
		if confirmPopup and confirmPopup.Parent then
			return confirmPopup
		end

		confirmPopup = repstor.Assets.GUI.ConfirmPopUp:Clone()
		confirmPopup.Parent = questMenu
		confirmPopup.Visible = false

		confirmPopup:GetPropertyChangedSignal("Visible"):Connect(function()
			if confirmPopup.Visible then
				tweenService:Create(abandonQuestButton.AbandonQuestText, info, {TextColor3 = Color3.fromRGB(255,154,213)}):Play()
				tweenService:Create(abandonQuestButton.RGBStroke, info, {ImageColor3 = Color3.fromRGB(255,154,213)}):Play()
				tweenService:Create(abandonQuestButton, info, {	ImageColor3 = Color3.fromRGB(60,49,88)}):Play()
			else
				tweenService:Create(abandonQuestButton, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
				tweenService:Create(abandonQuestButton.RGBStroke, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
				tweenService:Create(abandonQuestButton.AbandonQuestText, info, {	TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			end
		end)

		return confirmPopup
	end


	-----------------------------------------------------------------------------------------------------------------------------
	abandonQuestButton.MouseButton1Click:Connect(function()
		local popup = GetConfirmPopup()
		local confirmButton = popup["ConfirmButton(HoverClickSoundSizeChange)"]

		popup.TextLabel.Text = "Abandon Quest?"
		popup.Visible = true
		tweenService:Create(popup, info, {
			Size = UDim2.fromScale(0.262, 0.49)
		}):Play()

		if confirmConnection then
			confirmConnection:Disconnect()
		end

		confirmConnection = confirmButton.MouseButton1Click:Connect(function()
			local questName = abandonQuestButton.Parent.QuestName.Text
			repstor.Remotes.AbandonQuest:FireServer(questName)
			questMenu.QuestInfo.Visible = false
			popup.Visible = false
		end)
	end)


	-----------------------------------------------------------------------------------------------------------------------------
	abandonQuestButton.MouseEnter:Connect(function()
		if confirmPopup and not confirmPopup.Visible then
			tweenService:Create(abandonQuestButton, info, {ImageColor3 = Color3.fromRGB(87,107,194)}):Play()
		end
	end)


	-----------------------------------------------------------------------------------------------------------------------------
	abandonQuestButton.MouseLeave:Connect(function()
		if confirmPopup and not confirmPopup.Visible then
			tweenService:Create(abandonQuestButton, info, {	ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
		end
	end)
end