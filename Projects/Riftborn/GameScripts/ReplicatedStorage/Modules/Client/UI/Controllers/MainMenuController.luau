local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local UIHelper = require(ReplicatedStorage.Modules.Client.UI.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)

local MainMenuController = {}

function MainMenuController:Buttons()
	local info = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local info2 = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local MainMenu = UIManager:GetUI("MainMenu", "MainMenu")
	local blur: BlurEffect = Lighting.Blur
	for _, ui: ImageButton in MainMenu:GetChildren() do
		if ui:IsA("ImageButton") then
			UIHelper:Rotate(ui)
			UIHelper:ClickEffects(ui)
			UIHelper:HoverEffects(ui)

			local name = ui.Name:split("Button")[1]
			local frame = UIManager:GetUI(name .. "Menu", name .. "Menu")
			local border = ui:FindFirstChild("Border")
			local nameText = ui:FindFirstChild("ButtonName")
			local Texture = frame.Parent.Texture

			UIHelper:RotateGradient(border:FindFirstChild("UIGradient"))
			UIHelper:RotateGradient(nameText:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))

			ui.MouseButton1Click:Connect(function()
				MainMenu.Visible = false
				UIManager:SetActiveScreen(frame.Parent.Name)
				frame.Visible = true
				TweenService:Create(frame, info, { Size = UDim2.fromScale(1, 1) }):Play()

				TweenService:Create(blur, info2, { Size = 24 }):Play()
				TweenService:Create(Texture, info2, { ImageTransparency = 0.8 }):Play()
			end)

			ui.MouseEnter:Connect(function()
				nameText.Visible = true
			end)
			ui.MouseLeave:Connect(function()
				nameText.Visible = false
			end)

			UserInputService.InputBegan:Connect(function(inp, proc)
				if proc then
					return
				end
				if inp.KeyCode ~= Enum.KeyCode.M then
					return
				end
				if UIManager.ActiveScreen ~= frame.Parent.Name then
					return
				end
				TweenService:Create(Texture, info2, { ImageTransparency = 1 }):Play()

				local tween = TweenService:Create(frame, info, { Size = UDim2.fromScale(0, 0) })
				tween:Play()
				tween.Completed:Connect(function()
					frame.Visible = false
				end)
			end)
		end
	end
end

function MainMenuController:MainMenu()
	local blur: BlurEffect = Lighting.Blur
	local MainMenu = UIManager:GetUI("MainMenu", "MainMenu")
	local Texture = UIManager:GetUI("MainMenu", "Texture")
	UIHelper:RotateGradient(Texture:FindFirstChild("UIGradient"))

	local info = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local info2 = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	------M to open MainMenu------
	UserInputService.InputBegan:Connect(function(inp, proc)
		if proc then
			return
		end
		if inp.KeyCode == Enum.KeyCode.M then
			if UIManager.ActiveScreen == "MainMenu" then
				UIManager:SetActiveScreen("HUD")
				local tween = TweenService:Create(MainMenu, info, { Size = UDim2.fromScale(0, 0) })
				tween:Play()
				tween.Completed:Connect(function()
					MainMenu.Visible = false
				end)

				TweenService:Create(blur, info2, { Size = 0 }):Play()
				TweenService:Create(Texture, info2, { ImageTransparency = 1 }):Play()
			else
				UIManager:SetActiveScreen("MainMenu")
				MainMenu.Visible = true
				TweenService:Create(MainMenu, info, { Size = UDim2.fromScale(0.4, 0.9) }):Play()

				TweenService:Create(blur, info2, { Size = 24 }):Play()
				TweenService:Create(Texture, info2, { ImageTransparency = 0.8 }):Play()
			end
		end
	end)
end



return MainMenuController
