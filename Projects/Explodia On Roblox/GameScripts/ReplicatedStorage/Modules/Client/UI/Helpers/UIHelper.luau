local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIHelper = {}

UIHelper.Cache = {}

for _, menu in Players.LocalPlayer.PlayerGui:GetChildren() do
	UIHelper.Cache[menu] = {}

	for _, descendant in menu:GetDescendants() do
		if descendant:IsA("ImageButton") or descendant:IsA("ImageLabel") then
			UIHelper.Cache[menu][descendant] = {
				BackgroundTransparency = descendant.BackgroundTransparency,
				ImageTransparency = descendant.ImageTransparency,
			}
		elseif descendant:IsA("Frame") or descendant:IsA("ScrollingFrame") then
			UIHelper.Cache[menu][descendant] = {
				BackgroundTransparency = descendant.BackgroundTransparency,
			}
		elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			UIHelper.Cache[menu][descendant] = {
				BackgroundTransparency = descendant.BackgroundTransparency,
				TextTransparency = descendant.TextTransparency,
			}
		end
	end
end
function UIHelper:RotateGradient(gradient, duration)
	if gradient and gradient:IsA("UIGradient") then
		local info = TweenInfo.new((duration or 5), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
		TweenService:Create(gradient, info, { Rotation = 405 }):Play()
	end
end

function UIHelper:Lighten(color, amount)
	return color:Lerp(Color3.new(1, 1, 1), amount)
end

function UIHelper:Darken(color, amount)
	return color:Lerp(Color3.new(0, 0, 0), amount)
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


function UIHelper:ModifySize(ui: Instance, wantedScale)
	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local scale = ui:FindFirstChildWhichIsA("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = ui
	end
	TweenService:Create(scale, info, { Scale = tonumber(wantedScale) or 1 }):Play()
end

function UIHelper:SwitchGradients(UI_1, UI_2)
	local grad_1 = UI_1:FindFirstChild("UIGradient")
	local grad_2 = UI_2:FindFirstChild("UIGradient")
	grad_2.Parent = UI_1
	grad_1.Parent = UI_2
end

--TODO add selection effects , it will save so much messy code--
---TODO add hoverColor and ClickColor , will also save so much messy code--

function UIHelper:HoverColor(ui, property, enterColor, leaveColor, info)
	info = info or TweenInfo.new(0.0625, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	if typeof(enterColor) == "Color3" and typeof(leaveColor) == "Color3" then
		ui.MouseEnter:Connect(function()
			TweenService:Create(ui, info, { [property] = enterColor }):Play()
		end)
		ui.MouseLeave:Connect(function()
			TweenService:Create(ui, info, { [property] = leaveColor }):Play()
		end)
	end
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

function UIHelper:FadeIn(menu)
	local cache = UIHelper.Cache[menu]
	if not cache then
		return
	end
	menu.Enabled = true

	for obj, props in pairs(cache) do
		TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
	end
end

function UIHelper:FadeOut(menu)
	UIHelper.Cache[menu] = {}

	for _, descendant in ipairs(menu:GetDescendants()) do
		local goal = {}
		local original = {}

		if descendant:IsA("ImageButton") or descendant:IsA("ImageLabel") then
			original.BackgroundTransparency = descendant.BackgroundTransparency
			original.ImageTransparency = descendant.ImageTransparency

			goal.BackgroundTransparency = 1
			goal.ImageTransparency = 1
		elseif descendant:IsA("Frame") or descendant:IsA("ScrollingFrame") then
			original.BackgroundTransparency = descendant.BackgroundTransparency

			goal.BackgroundTransparency = 1
		elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			original.BackgroundTransparency = descendant.BackgroundTransparency
			original.TextTransparency = descendant.TextTransparency

			goal.BackgroundTransparency = 1
			goal.TextTransparency = 1
		end

		if next(original) then
			UIHelper.Cache[menu][descendant] = original

			TweenService:Create(descendant, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
				:Play()
		end
	end

	task.wait(0.2)
	menu.Enabled = false
end

return UIHelper
