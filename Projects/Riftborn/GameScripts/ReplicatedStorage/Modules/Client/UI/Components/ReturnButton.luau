return function(menu, returnButton)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")
	local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
	local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
	local mainMenu = UIManager:GetUI("MainMenu", "MainMenu")

	UIHelper:ClickEffects(returnButton)
	UIHelper:HoverEffects(returnButton)
	UIHelper:RotateGradient(returnButton:FindFirstChild("Stroke"):FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(returnButton:FindFirstChild("XFill"):FindFirstChild("Stroke"):FindFirstChild("UIGradient"))

	local info = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

	returnButton.MouseButton1Click:Connect(function()
		TweenService:Create(menu, info, { Size = UDim2.fromScale(0, 0) }):Play()
		menu.Visible = false

		if UIManager.ActiveScreen == "MainMenu" then
			UIManager:SetActiveScreen("HUD")
		else
			
			UIManager:SetActiveScreen("MainMenu")
			mainMenu.Visible = true
			TweenService:Create(mainMenu, info, { Size = UDim2.fromScale(0.4, 0.9) }):Play()
		end
	end)
end
