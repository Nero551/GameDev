local DefaultProperties = {}

DefaultProperties.Frame = {
    AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromScale(0.2, 0.1),
	Position = UDim2.fromScale(0.4, 0.45),
	BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	BorderSizePixel = 0,
	BackgroundTransparency = 0,
	ClipsDescendants = false,
	Visible = true,
}

DefaultProperties.TextLabel = {
    AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromScale(1, 0.3),
	Position = UDim2.fromScale(0, 0),
	BackgroundTransparency = 1,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.SourceSans,
	TextScaled = true,
	Text = "",
	Visible = true,
}

DefaultProperties.TextButton = {
    AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromScale(0.2, 0.1),
	BackgroundColor3 = Color3.fromRGB(80, 80, 80),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.SourceSansBold,
	TextScaled = true,
	Text = "Button",
	BorderSizePixel = 0,
	Visible = true,
}

DefaultProperties.TextBox = {
    AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromScale(0.2, 0.1),
	BackgroundColor3 = Color3.fromRGB(70, 70, 70),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.SourceSans,
	TextScaled = true,
	Text = "",
	ClearTextOnFocus = false,
	BorderSizePixel = 0,
	Visible = true,
}

DefaultProperties.ImageButton = {
    AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromScale(0.1, 0.1),
	BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	BorderSizePixel = 0,
	Visible = true,
	AutoButtonColor = true,
}

DefaultProperties.ScreenGui = {
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 1,
	Enabled = true,
}

DefaultProperties.UIGradient = {
	Rotation = 0,
	Transparency = NumberSequence.new(0),
	Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
}

DefaultProperties.UIStroke = {
	Thickness = 2,
	Color = Color3.fromRGB(255, 255, 255),
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	LineJoinMode = Enum.LineJoinMode.Round,
}

return DefaultProperties
