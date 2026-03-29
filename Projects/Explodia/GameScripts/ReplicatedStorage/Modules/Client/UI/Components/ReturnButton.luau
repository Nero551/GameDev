return function(menu)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
	local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
	local returnButton = UIManager:GetUI(menu, "ReturnButton")

	UIHelper:ClickEffects(returnButton)
	UIHelper:HoverEffects(returnButton)
	
	returnButton.MouseButton1Click:Connect(function()
		if UIManager.ActiveScreen == "MainMenu" then
			UIManager:SetActiveScreen("HUD")
		else
			UIManager:SetActiveScreen("MainMenu")
		end
	end)
end
