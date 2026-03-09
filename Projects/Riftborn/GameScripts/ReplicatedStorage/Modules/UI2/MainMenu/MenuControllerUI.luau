return function()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer

local blur:BlurEffect = Lighting.Blur
local MainMenu = Player:WaitForChild("PlayerGui"):WaitForChild("MenusGUI"):WaitForChild("MainMenu")
local menuGui = MainMenu.Parent
local Texture = menuGui.Texture

local info = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

local function BackgroundBlurTweenIn()
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(blur, info, {Size = 24}):Play()
	TweenService:Create(Texture, info, {ImageTransparency = 0.8}):Play()
end

local function BackgroundBlurTweenOut()
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(blur, info, {Size = 0}):Play()
	TweenService:Create(Texture, info, {ImageTransparency = 1}):Play()
end



local Buttons = {}

for _, ui:ImageButton? in MainMenu:GetChildren() do
	if ui:IsA("ImageButton") then
		Buttons[ui] = {
			frame = menuGui[ui.Name:split("Button")[1].."Menu"], 
			border = ui:FindFirstChild("Border(ClickSound)"),
			nameText = ui:FindFirstChild("ButtonName")
		}
	end	
end

for ui, data in pairs(Buttons) do
	------Rotate when hovering
	local function Rotate()
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween =  TweenService:Create(ui , info, {Rotation = -8}):Play()
	end
	local function RotateBack()
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(ui, info, {Rotation = 0}):Play()
	end

	------Button To Open Menu Functions------
	local function CloseAllOtherMenus()
		for _,child in ipairs(menuGui:GetChildren()) do
			if child:IsA("Frame") and child ~= data.frame then

				TweenService:Create(child, info, {Size = UDim2.fromScale(0,0)}):Play()
				child.Visible = false
			end
		end
	end

	local function OpenYourMenu()
		data.frame.Visible = true
		TweenService:Create(data.frame , info, {Size = UDim2.fromScale(1,1)}):Play()
	end

	local function CloseYourMenu()
		local tween = TweenService:Create(data.frame, info, {Size = UDim2.fromScale(0,0)})
		tween:Play()
		tween.Completed:Connect(function()
			data.frame.Visible = false
		end)
	end

	ui.MouseEnter:Connect(function()
		data.nameText.Visible = true
		Rotate()
	end)
	ui.MouseLeave:Connect(function()
		data.nameText.Visible = false
		RotateBack()
	end)

	data.border.MouseButton1Click:Connect(function()
		CloseAllOtherMenus()
		OpenYourMenu()
		BackgroundBlurTweenIn()
	end)

	UserInputService.InputBegan:Connect(function(inp, proc)
		if proc then return end
		if inp.KeyCode == Enum.KeyCode.M then
			CloseYourMenu()
		end
	end)
end


------M to open MainMenu------ 
local function OpenMenu()
	MainMenu.Visible = true
	TweenService:Create(MainMenu, info, {Size = UDim2.fromScale(0.4, 0.9)}):Play()
end

local function CloseMenu()
	local tween = TweenService:Create(MainMenu, info, {Size = UDim2.fromScale(0,0)})
	tween:Play()
	tween.Completed:Connect(function()
		MainMenu.Visible = false
	end)
end

UserInputService.InputBegan:Connect(function(inp, proc)
	if proc then return end	
	if inp.KeyCode == Enum.KeyCode.M then
		if MainMenu.Size == UDim2.fromScale(0,0) then
			for _,otherMenu in menuGui:GetChildren() do
				if otherMenu:IsA("Frame") then
					if otherMenu.Size == UDim2.fromScale(0,0) then
						OpenMenu()
					end
				end
			end
			BackgroundBlurTweenIn()
		elseif MainMenu.Size == UDim2.fromScale(0.4, 0.9) then
			CloseMenu()
			BackgroundBlurTweenOut()
		end
	end
end)

end