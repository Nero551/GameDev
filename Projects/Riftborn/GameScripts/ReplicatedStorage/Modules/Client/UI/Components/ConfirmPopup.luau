local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)

return function()
	local confirmPopUp = ReplicatedStorage.Assets.UI.ConfirmPopUp:Clone()
	confirmPopUp.Parent = UIManager:GetUI("Popups", "ConfirmPopups")
	confirmPopUp.Visible = false

	UIHelper:RotateGradient(confirmPopUp:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))
	local cancelButton = confirmPopUp:FindFirstChild("CancelButton")
	UIHelper:ClickEffects(cancelButton)
	UIHelper:HoverEffects(cancelButton)
	UIHelper:RotateGradient(cancelButton:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(cancelButton:FindFirstChild("RGBStroke"):FindFirstChild("UIGradient"))

	local confirmButton = confirmPopUp:FindFirstChild("ConfirmButton")
	UIHelper:HoverEffects(confirmButton)
	UIHelper:ClickEffects(confirmButton)
	UIHelper:RotateGradient(confirmButton:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(confirmButton:FindFirstChild("RGBStroke"):FindFirstChild("UIGradient"))

	local info = TweenInfo.new(0.0625, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	cancelButton.MouseEnter:Connect(function()
		tweenService:Create(cancelButton.CancelText, info, { TextColor3 = Color3.fromRGB(255, 154, 213) }):Play()
		tweenService:Create(cancelButton.RGBStroke, info, { ImageColor3 = Color3.fromRGB(255, 154, 213) }):Play()
		tweenService:Create(cancelButton, info, { ImageColor3 = Color3.fromRGB(60, 49, 88) }):Play()
	end)

	cancelButton.MouseLeave:Connect(function()
		tweenService:Create(cancelButton.CancelText, info, { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		tweenService:Create(cancelButton.RGBStroke, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		tweenService:Create(cancelButton, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)

	cancelButton.MouseButton1Click:Connect(function()
		local tween = tweenService:Create(confirmPopUp, info, { Size = UDim2.fromScale(0, 0) })
		tween:Play()
		tween.Completed:Connect(function()
			confirmPopUp.Visible = false
			confirmPopUp:Destroy()
		end)
	end)

	confirmButton.MouseEnter:Connect(function()
		tweenService:Create(confirmButton.ConfirmText, info, { TextColor3 = Color3.fromRGB(255, 154, 213) }):Play()
		tweenService:Create(confirmButton.RGBStroke, info, { ImageColor3 = Color3.fromRGB(255, 154, 213) }):Play()
		tweenService:Create(confirmButton, info, { ImageColor3 = Color3.fromRGB(60, 49, 88) }):Play()
	end)

	confirmButton.MouseLeave:Connect(function()
		tweenService:Create(confirmButton.ConfirmText, info, { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		tweenService:Create(confirmButton.RGBStroke, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		tweenService:Create(confirmButton, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
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
