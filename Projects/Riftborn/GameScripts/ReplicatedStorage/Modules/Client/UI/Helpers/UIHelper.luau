local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIHelper = {}

local hoverSound = ReplicatedStorage.Assets.Shared.Sounds.MenuSounds.Hover
local clickSound = ReplicatedStorage.Assets.Shared.Sounds.MenuSounds.Click

function UIHelper:RotateGradient(gradient, duration)
	if gradient and gradient:IsA("UIGradient") then
		local info = TweenInfo.new((duration or 5), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
		TweenService:Create(gradient, info, { Rotation = 405 }):Play()
	end
end

function UIHelper:Rotate(ui)
	local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	ui.MouseEnter:Connect(function()
		TweenService:Create(ui, info, { Rotation = -8 }):Play()
	end)
	ui.MouseLeave:Connect(function()
		TweenService:Create(ui, info, { Rotation = 0 }):Play()
	end)
end

function UIHelper:HoverEffects(ui)
	if not ui then return end
	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local scale = ui:FindFirstChildWhichIsA("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = ui
	end
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
		scale = Instance.new("UIScale")
		scale.Parent = ui
	end
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

function UIHelper:SelectedEffects(ui)

end

function UIHelper:CreateGradient(colorTable)
	if typeof(colorTable) ~= "table" then
		return
	end

	local keypoints = {}
	table.sort(colorTable, function(a, b)
		return a.Position < b.Position
	end)
	for _, color in ipairs(colorTable) do
		local r, g, b = color.Color:match("(%d+),%s*(%d+),%s*(%d+)")
		local c3 = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
		table.insert(keypoints, ColorSequenceKeypoint.new(color.Position, c3))
	end
	return ColorSequence.new(keypoints)
end

return UIHelper
