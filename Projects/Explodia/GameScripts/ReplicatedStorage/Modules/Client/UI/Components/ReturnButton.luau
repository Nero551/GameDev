return function(menu)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClickHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.ClickHelper)
local HoverHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.HoverHelper)
	local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
	local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
	local returnButton = UIManager:GetUI(menu, "ReturnButton")

	ClickHelper:ClickEffects(returnButton)
	HoverHelper:HoverEffects(returnButton)
	
	returnButton.MouseButton1Click:Connect(function()
		if UIManager.ActiveScreen == "MainMenu" then
			UIManager:SetActiveScreen("HUD")
		else
			UIManager:SetActiveScreen("MainMenu")
		end
	end)
end
