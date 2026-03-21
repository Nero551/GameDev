local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.Core.NetworkingService)
return function(questMenu, abandonQuestButton)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")


	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local confirmPopup
	local confirmConnection
	
	local CloneConfirmPopupUI = require(script.Parent.Parent.CloneConfirmPopupUI)

	local function GetConfirmPopup()
		if confirmPopup and confirmPopup.Parent then
			return confirmPopup
		end

		confirmPopup = CloneConfirmPopupUI()

		confirmPopup:GetPropertyChangedSignal("Visible"):Connect(function()
			if confirmPopup.Visible then
				TweenService:Create(abandonQuestButton.AbandonQuestText, info, {TextColor3 = Color3.fromRGB(255,154,213)}):Play()
				TweenService:Create(abandonQuestButton.RGBStroke, info, {ImageColor3 = Color3.fromRGB(255,154,213)}):Play()
				TweenService:Create(abandonQuestButton, info, {	ImageColor3 = Color3.fromRGB(60,49,88)}):Play()
			else
				TweenService:Create(abandonQuestButton, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
				TweenService:Create(abandonQuestButton.RGBStroke, info, {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
				TweenService:Create(abandonQuestButton.AbandonQuestText, info, {	TextColor3 = Color3.fromRGB(255,255,255)}):Play()
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
		TweenService:Create(popup, info, {
			Size = UDim2.fromScale(0.262, 0.49)
		}):Play()

		if confirmConnection then
			confirmConnection:Disconnect()
		end

		confirmConnection = confirmButton.MouseButton1Click:Connect(function()
			local questName = abandonQuestButton.Parent.QuestName.Text
			NetworkingService:FireToServer("AbandonQuest", questName)
			questMenu.QuestInfo.Visible = false
			popup.Visible = false
		end)
	end)


	-----------------------------------------------------------------------------------------------------------------------------
	abandonQuestButton.MouseEnter:Connect(function()
		if confirmPopup and not confirmPopup.Visible then
			TweenService:Create(abandonQuestButton, info, {ImageColor3 = Color3.fromRGB(87,107,194)}):Play()
		end
	end)


	-----------------------------------------------------------------------------------------------------------------------------
	abandonQuestButton.MouseLeave:Connect(function()
		if confirmPopup and not confirmPopup.Visible then
			TweenService:Create(abandonQuestButton, info, {	ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
		end
	end)
end