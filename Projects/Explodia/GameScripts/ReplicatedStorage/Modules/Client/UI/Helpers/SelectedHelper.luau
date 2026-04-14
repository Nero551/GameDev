local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local Theme = player:WaitForChild("Settings"):WaitForChild("Theme")
local SelectedHelper = {}

local prevUISelected = {}
local UISelected = {}

function SelectedHelper:ColorEffect(ui, catagoryName)
	if not ui then
		return
	end
	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	ui.MouseButton1Click:Connect(function()
		if ui:IsA("TextButton") then
			local baseTextColor = Theme:GetAttribute("Text_Primary")
			local baseBackgroundColor = Theme:GetAttribute("Button_Background")
			prevUISelected[catagoryName] = UISelected[catagoryName]
			UISelected[catagoryName] = ui

			if UISelected[catagoryName] ~= nil then
				UISelected[catagoryName]:SetAttribute("Selected", true)
				TweenService:Create(
					UISelected[catagoryName]:FindFirstChildWhichIsA("TextLabel"),
					info,
					{ TextColor3 = baseBackgroundColor }
				):Play()
				TweenService:Create(UISelected[catagoryName], info, { BackgroundColor3 = baseTextColor }):Play()

				if prevUISelected[catagoryName] ~= nil then
					if prevUISelected[catagoryName] ~= UISelected[catagoryName] then
						prevUISelected[catagoryName]:SetAttribute("Selected", nil)
						TweenService
							:Create(prevUISelected[catagoryName], info, { BackgroundColor3 = baseBackgroundColor })
							:Play()
						TweenService:Create(
							prevUISelected[catagoryName]:FindFirstChildWhichIsA("TextLabel"),
							info,
							{ TextColor3 = baseTextColor }
						):Play()
					end
				end
			end
		end
		if ui:IsA("ImageButton") then
			local baseStroke = Theme:GetAttribute("Stroke")
			local baseTextColor = Theme:GetAttribute("Text_Primary")

			prevUISelected[catagoryName] = UISelected[catagoryName]
			UISelected[catagoryName] = ui

			if UISelected[catagoryName] ~= nil then
				UISelected[catagoryName]:SetAttribute("Selected", true)
				TweenService:Create(UISelected[catagoryName].UIStroke, info, { Color = baseTextColor }):Play()

				if prevUISelected[catagoryName] ~= nil then
					if prevUISelected[catagoryName] ~= UISelected[catagoryName] then
						prevUISelected[catagoryName]:SetAttribute("Selected", nil)
						TweenService:Create(prevUISelected[catagoryName].UIStroke, info, { Color = baseStroke }):Play()
					end
				end
			end
		end
	end)
end

function SelectedHelper:SizeEffect(ui, down, up)
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

function SelectedHelper:SelectedEffects(ui, catagoryName, down, up)
	Theme.AttributeChanged:Connect(function()
		SelectedHelper:ColorEffect(ui, catagoryName)
	end)
	SelectedHelper:ColorEffect(ui, catagoryName)
	--SelectedHelper:SizeEffect(ui, down, up)
end
return SelectedHelper
