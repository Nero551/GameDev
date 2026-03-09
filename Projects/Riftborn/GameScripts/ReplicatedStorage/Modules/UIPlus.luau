local TweenService = game:GetService("TweenService")
local UIPlus = {}

function UIPlus:RotateGradient(grad)
	if grad:IsA("UIGradient") then
		if string.find(grad.Name, "RotGrad") then
			local info = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
			TweenService:Create(grad, info, { Rotation = 405 }):Play()
		end
	end
end

function UIPlus:HoverScale(ui)
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

function UIPlus:ClickScale(ui)
    if not ui:IsA("TextButton") or not ui:IsA("ImageButton") then return end
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

return UIPlus
