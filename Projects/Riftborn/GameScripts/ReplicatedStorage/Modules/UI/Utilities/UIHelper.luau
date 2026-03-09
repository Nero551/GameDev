local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIFactory = require(script.Parent.UIFactory)
local UIHelper = {}

local hoverSound = ReplicatedStorage.Assets.Shared.Sounds.MenuSounds.Hover
local clickSound = ReplicatedStorage.Assets.Shared.Sounds.MenuSounds.Click

function UIHelper:RotateGradient(gradName)
	local grad = UIFactory.UI[gradName]
	if grad then
		local info = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
		TweenService:Create(grad, info, { Rotation = 405 }):Play()
	end
end

function UIHelper:Select(ui)
	local UISelected
	local prevUISelected

	local scale = ui:FindFirstChildWhichIsA("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = ui
	end

	ui.MouseEnter:Connect(function()
		hoverSound:Play()
		ui.ImageColor3 = Color3.fromHex("#eeeeee")

		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, { Scale = 1.05 }):Play()

		if UISelected ~= ui then
			if ui.Border then
				TweenService:Create(ui.Border, info, { ImageColor3 = Color3.fromRGB(71, 88, 158) }):Play()				
			end
		end
	end)

	ui.MouseLeave:Connect(function()
		ui.ImageColor3 = Color3.fromHex("#ffffff")
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, { Scale = 1 }):Play()
	

		if UISelected ~= ui then
			if ui.Border then
				TweenService:Create(ui.Border, info, { ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()				
			end
		end
	end)
end

function UIHelper:HoverScale(ui)
	local scale = ui:FindFirstChildWhichIsA("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = ui
	end
	ui.MouseEnter:Connect(function()
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, { Scale = 1.05 }):Play()
	end)

	ui.MouseLeave:Connect(function()
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, { Scale = 1 }):Play()
	end)
end

function UIHelper:ClickScale(ui)
	if not ui:IsA("TextButton") or not ui:IsA("ImageButton") then
		return
	end
	local scale = ui:FindFirstChildWhichIsA("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = ui
	end
	ui.MouseButton1Down:Connect(function()
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, { Scale = 1.05 }):Play()
	end)

	ui.MouseButton1Up:Connect(function()
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, { Scale = 1 }):Play()
	end)
end

return UIHelper
