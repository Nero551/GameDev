local DefaultProperties = {}

DefaultProperties.Frame = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromScale(0.2, 0.1),
	Position = UDim2.fromScale(0.5, 0.5),
	ZIndex = 1,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BorderSizePixel = 0,
	BackgroundTransparency = 0,
	ClipsDescendants = false,
	Visible = true,
}

DefaultProperties.TextLabel = {
	AnchorPoint = Vector2.new(0, 0),
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromScale(0.5, 0.5),
	ZIndex = 1,
	BackgroundTransparency = 1,
	TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
	TextColor3 = Color3.fromRGB(240,235,216),
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	FontFace = Font.new("rbxasset://fonts/families/Jura.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	TextScaled = true,
	Text = "",
	Visible = true,
}

DefaultProperties.ImageLabel = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	Size = UDim2.fromScale(0.1, 0.1),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 1,
	Visible = true,
	ImageColor3 = Color3.fromRGB(255, 255, 255),
	ImageTransparency = 0,
	ScaleType = "Stretch",
	ResampleMode = "Default",
}

DefaultProperties.TextButton = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromScale(0.2, 0.1),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundTransparency = 1,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	FontFace = Font.new("rbxasset://fonts/families/Rajdhani.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	TextScaled = true,
	Text = "Button",
	BorderSizePixel = 0,
	ZIndex = 1,
	Visible = true,
}

DefaultProperties.ImageButton = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromScale(0.1, 0.1),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 1,
	Visible = true,
	ImageColor3 = Color3.fromRGB(255, 255, 255),
	ImageTransparency = 0,
	ScaleType = "Stretch",
	ResampleMode = "Default",
}

DefaultProperties.TextBox = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromScale(0.2, 0.1),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 1,
	ZIndex = 1,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	FontFace = Font.new("rbxasset://fonts/families/Rajdhani.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	TextScaled = true,
	Text = "",
	ClearTextOnFocus = false,
	BorderSizePixel = 0,
	Visible = true,
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
