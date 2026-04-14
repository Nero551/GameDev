local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local ClickHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.ClickHelper)
local HoverHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.HoverHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
local player = Players.LocalPlayer

return function()
	local confirmPopUp = player.PlayerGui.UITemplates.ConfirmPopUp:Clone()
	confirmPopUp.Parent = UIManager:GetUI("Popups", "ConfirmPopups")
	confirmPopUp.Visible = false

	local cancelButton = confirmPopUp:FindFirstChild("CancelButton")
	local confirmButton = confirmPopUp:FindFirstChild("ConfirmButton")

	ClickHelper:ClickEffects(cancelButton)
	HoverHelper:HoverEffects(cancelButton)

	HoverHelper:HoverEffects(confirmButton)
	ClickHelper:ClickEffects(confirmButton)

	local info = TweenInfo.new(0.0625, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)


	cancelButton.MouseButton1Click:Connect(function()
		local tween = tweenService:Create(confirmPopUp, info, { Size = UDim2.fromScale(0, 0) })
		tween:Play()
		tween.Completed:Connect(function()
			confirmPopUp.Visible = false
			confirmPopUp:Destroy()
		end)
	end)

	confirmButton.MouseButton1Click:Connect(function()
		local tween = tweenService:Create(confirmPopUp, info, { Size = UDim2.fromScale(0, 0) })
		tween:Play()
		tween.Completed:Connect(function()
			confirmPopUp.Visible = false
			confirmPopUp:Destroy()
		end)
	end)

	return confirmPopUp
end
