local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIFactory = require(ReplicatedStorage.Modules.UI.Utilities.UIFactory)
local UIHelper = require(ReplicatedStorage.Modules.UI.Utilities.UIHelper)
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local HUDController = {}

local playerCurrency = player:WaitForChild("Currencies")

UIFactory:Create("HUDScreen", "ScreenGui", nil, {
	IgnoreGuiInset = true,
})

UIFactory:Create("StatusFrame", "Frame", "HUDScreen", {
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.fromScale(0, 0.69),
	Size = UDim2.fromScale(0.408, 0.296),
	BackgroundTransparency = 1,
	KeepAspectRatio = true,
})

function HUDController:Currencies()
	UIFactory:Create("CurrencyFrame", "Frame", "StatusFrame", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0.241, 0.2),
		Size = UDim2.fromScale(0.249, 0.192),
		BackgroundTransparency = 1,
		KeepAspectRatio = true,
	})

	UIFactory:Create("YenIcon", "ImageLabel", "CurrencyFrame", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0.1, 0.617),
		Size = UDim2.fromScale(0.186, 0.398),
		Image = "rbxassetid://110751007066288",
		KeepAspectRatio = true,
	})

	UIFactory:Create("FractaIcon", "ImageLabel", "CurrencyFrame", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0.1, 0.117),
		Size = UDim2.fromScale(0.186, 0.398),
		Image = "rbxassetid://114060338374650",
		KeepAspectRatio = true,
	})

	UIFactory:Create("YenNumber", "TextLabel", "CurrencyFrame", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0.229, 0.026),
		Size = UDim2.fromScale(0.776, 0.579),
		KeepAspectRatio = true,
		Text = playerCurrency.Yen:GetAttribute("Amount"),
	})

	UIFactory:Create("FractaNumber", "TextLabel", "CurrencyFrame", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0.229, 0.526),
		Size = UDim2.fromScale(0.776, 0.579),
		KeepAspectRatio = true,
		Text = playerCurrency.Fracta:GetAttribute("Amount"),
	})

	UIFactory:Create("FractaNumber.UIGradient", "UIGradient", "FractaNumber", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 11, 15)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 181, 241)),
		}),
		Rotation = 45,
	})

	UIFactory:Create("YenNumber.UIGradient", "UIGradient", "YenNumber", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 189, 74)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(247, 255, 92)),
		}),
		Rotation = 45,
	})

	for _, type in playerCurrency:GetChildren() do
		type.AttributeChanged:Connect(function()
			UIFactory:ModifyProperty(type.Name .. "Number", {
				Text = type:GetAttribute("Amount"),
			})
		end)
	end
end

function HUDController:HealthBar()
	UIFactory:Create("HealthBG", "ImageLabel", "StatusFrame", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0.272, 0.535),
		Size = UDim2.fromScale(0.806, 0.141),
		Image = "rbxassetid://73156659295079",
		KeepAspectRatio = true,
	})
	UIFactory:Create("HealthFill", "ImageLabel", "HealthBG", {
		AnchorPoint = Vector2.new(0, 0),
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		Image = "rbxassetid://100051394754850",
	})
	UIFactory:Create("HealthFill.UIGradient", "UIGradient", "HealthFill", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(218, 218, 218)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(234, 234, 234)),
		}),
		Rotation = 90,
	})
	UIHelper:RotateGradient("HealthFill.UIGradient")

	UIFactory:Create("Shadow", "ImageLabel", "HealthBG", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1.025, 1.025),
		Image = "rbxassetid://73156659295079",
		ImageTransparency = 0.8,
		KeepAspectRatio = true,
	})
	UIFactory:Create("HealthBG.Stroke", "ImageLabel", "HealthBG", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1, 1),
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		Image = "rbxassetid://136885756794724",
		ImageTransparency = 0.5,
		KeepAspectRatio = true,
	})
	UIFactory:Create("HealthBG.Stroke.UIGradient", "UIGradient", "HealthBG.Stroke", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 207, 152)),
		}),
		Rotation = 90,
	})
	UIHelper:RotateGradient("HealthBG.Stroke.UIGradient")

	UIFactory:Create("HealthNumber", "TextLabel", "HealthBG", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0.548, 0),
		Size = UDim2.fromScale(0.345, 1),
		Text = character:GetAttribute("Health_CurrentHealth") .. " / " .. character:GetAttribute("Health_MaxHealth"),
		TextStrokeTransparency = 0,
		["Font.Bold"] = true,
		["Font.Style"] = true,
		KeepAspectRatio = true,
	})
	UIFactory:Create("HealthNumber.UIGradient", "UIGradient", "HealthNumber", {
		ColorSequence.new(Color3.fromRGB(230, 235, 255)),
	})
	UIFactory:Create("HealthText", "TextLabel", "HealthBG", {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(-0.003, 0),
		Zindex = 3,
		Size = UDim2.fromScale(0.345, 1),
		["Font.Bold"] = true,
		Text = "HEALTH",
		KeepAspectRatio = true,
	})
	UIFactory:Create("HealthText.UIGradient", "UIGradient", "HealthText", {
		ColorSequence.new(Color3.fromRGB(230, 235, 255)),
	})

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	character:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(function()
		UIFactory:ModifyProperty("HealthNumber", {
			Text = character:GetAttribute("Health_CurrentHealth") .. " / " .. character:GetAttribute(
				"Health_MaxHealth"
			),
		})
		TweenService:Create(UIFactory.UI.HealthFill, info, {
			Size = UDim2.fromScale(
				(character:GetAttribute("Health_CurrentHealth") / character:GetAttribute("Health_MaxHealth")),
				1
			),
		}):Play()
	end)
	character:GetAttributeChangedSignal("Health_MaxHealth"):Connect(function()
		UIFactory:ModifyProperty("HealthNumber", {
			Text = character:GetAttribute("Health_CurrentHealth") .. " / " .. character:GetAttribute(
				"Health_MaxHealth"
			),
		})
		TweenService:Create(UIFactory.UI.HealthFill, info, {
			Size = UDim2.fromScale(
				(character:GetAttribute("Health_CurrentHealth") / character:GetAttribute("Health_MaxHealth")),
				1
			),
		}):Play()
	end)
end


HUDController:Currencies()
HUDController:HealthBar()

return HUDController
