local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIHelper = require(script.Parent.UIHelper)
local player = Players.LocalPlayer
local Theme = player:WaitForChild("Settings"):WaitForChild("Theme")
local HoverHelper = {}

function HoverHelper:ColorEffect(ui)
	if not ui then
		return
	end
	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	if ui:IsA("TextButton") then
		local hoverColor = UIHelper:Lighten(Theme:GetAttribute("Button_Background"), 0.08)

		ui.MouseEnter:Connect(function()
			if not ui:GetAttribute("Selected") then
				TweenService:Create(ui, info, {
					BackgroundColor3 = hoverColor,
				}):Play()
			end
		end)

		ui.MouseLeave:Connect(function()
			if not ui:GetAttribute("Selected") then
				TweenService:Create(ui, info, {
					BackgroundColor3 = Theme:GetAttribute("Button_Background"),
				}):Play()
			end
		end)
	end
	if ui:IsA("ImageButton") then
		local hoverColor = UIHelper:Lighten(Theme:GetAttribute("Stroke"), 0.08)
		ui.MouseEnter:Connect(function()
			if not ui:GetAttribute("Selected") then
				TweenService:Create(ui.UIStroke, info, {
					Color = hoverColor,
				}):Play()
			end
		end)

		ui.MouseLeave:Connect(function()
			if not ui:GetAttribute("Selected") then
				TweenService:Create(ui.UIStroke, info, {
					Color = Theme:GetAttribute("Stroke"),
				}):Play()
			end
		end)
	else
	end
end

function HoverHelper:SizeEffect(ui, enter, leave)
	if not ui then
		return
	end
	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local scale = ui:FindFirstChildWhichIsA("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = ui
	end

	ui.MouseEnter:Connect(function()
		if not ui:GetAttribute("Selected") then
			TweenService:Create(scale, info, { Scale = (enter or 1.05) }):Play()
		end
	end)
	ui.MouseLeave:Connect(function()
		if not ui:GetAttribute("Selected") then
			TweenService:Create(scale, info, { Scale = (leave or 1) }):Play()
		end
	end)
end

function HoverHelper:SoundEffect(ui)
	ui.MouseEnter:Connect(function()
		ReplicatedStorage.Assets.MenuSounds.Hover:Play()
	end)
end

function HoverHelper:HoverEffects(ui, enter, leave)
	Theme.AttributeChanged:Connect(function()
		HoverHelper:ColorEffect(ui)
	end)
	HoverHelper:ColorEffect(ui)

	HoverHelper:SizeEffect(ui, enter, leave)
	HoverHelper:SoundEffect(ui)
end

return HoverHelper
