local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIManager = require(script.Parent.UIManager)
local UIHelper = {}

function UIHelper:RotateGradient(gradient)
	if gradient and gradient:IsA("UIGradient") then
		local info = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
		TweenService:Create(gradient, info, { Rotation = 405 }):Play()
	end
end

function UIHelper:HoverEffects(ui)
	if not ui then return end
	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local scale = ui:FindFirstChildWhichIsA("UIScale")
	if not scale then
		scale = UIManager:CreateUI("HUD", "UIScale", "UIScale", ui.Name, {})
	end
	local hoverSound = ReplicatedStorage.Assets.Shared.Sounds.MenuSounds.Hover
	ui.MouseEnter:Connect(function()
		TweenService:Create(scale, info, { Scale = 1.1 }):Play()
		hoverSound:Play()
	end)
	ui.MouseLeave:Connect(function()
		TweenService:Create(scale, info, {Scale = 1}):Play()
	end)
end

function UIHelper:ClickEffects(ui)
	if not ui then return end
	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local scale = ui:FindFirstChildWhichIsA("UIScale")
	if not scale then
		scale = UIManager:CreateUI("HUD", "UIScale", "UIScale", ui.Name, {})
	end
	local clickSound = ReplicatedStorage.Assets.Shared.Sounds.MenuSounds.Click
	ui.MouseButton1Click:Connect(function()
		clickSound:Play()
	end)

	ui.MouseButton1Down:Connect(function()
		TweenService:Create(scale, info, { Scale = 0.975 }):Play()
	end)
	ui.MouseButton1Up:Connect(function()
		TweenService:Create(scale, info, {Scale = 1.1}):Play()
	end)
end

return UIHelper
