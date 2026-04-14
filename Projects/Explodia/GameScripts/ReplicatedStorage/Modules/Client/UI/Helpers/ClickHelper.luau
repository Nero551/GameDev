local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIHelper = require(script.Parent.UIHelper)
local player = Players.LocalPlayer
local Theme = player:WaitForChild("Settings"):WaitForChild("Theme")
local ClickHelper = {}

function ClickHelper:ColorEffect(ui)
	if not ui then
		return
	end
	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	if ui:IsA("TextButton") then
		local hoverColor = UIHelper:Lighten(Theme:GetAttribute("Button_Background"), 0.08)
		local clickColor = UIHelper:Darken(Theme:GetAttribute("Button_Background"), 0.08)

		ui.MouseButton1Down:Connect(function()
			TweenService:Create(ui, info, {
				BackgroundColor3 = clickColor,
			}):Play()
		end)

		ui.MouseButton1Up:Connect(function()
			if not ui:GetAttribute("Selected") then
				TweenService:Create(ui, info, {
					BackgroundColor3 = hoverColor,
				}):Play()
			end
		end)
	end
	if ui:IsA("ImageButton") then
		local hoverColor = UIHelper:Lighten(Theme:GetAttribute("Stroke"), 0.08)
		local clickColor = UIHelper:Darken(Theme:GetAttribute("Stroke"), 0.08)

		ui.MouseButton1Down:Connect(function()
			TweenService:Create(ui, info, {
				BackgroundColor3 = clickColor,
			}):Play()
		end)

		ui.MouseButton1Up:Connect(function()
			if not ui:GetAttribute("Selected") then
				TweenService:Create(ui, info, {
					BackgroundColor3 = hoverColor,
				}):Play()
			end
		end)
	end
end

function ClickHelper:SizeEffect(ui, down, up)
	if not ui then
		return
	end
	local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local scale = ui:FindFirstChildWhichIsA("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = ui
	end

	ui.MouseButton1Down:Connect(function()
		TweenService:Create(scale, info, { Scale = (down or 0.975) }):Play()
	end)
	ui.MouseButton1Up:Connect(function()
		TweenService:Create(scale, info, { Scale = (up or 1.05) }):Play()
	end)
end

function ClickHelper:SoundEffect(ui)
	ui.MouseButton1Click:Connect(function()
		ReplicatedStorage.Assets.MenuSounds.Click:Play()
	end)
end

function ClickHelper:ClickEffects(ui, down, up)
	Theme.AttributeChanged:Connect(function()
		ClickHelper:ColorEffect(ui)
	end)
	ClickHelper:ColorEffect(ui)
	ClickHelper:SizeEffect(ui, down, up)
	ClickHelper:SoundEffect(ui)
end

return ClickHelper
