local Players = game:GetService("Players")
local UIManager = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

UIManager.Screens = {}
UIManager.Controllers = {}
UIManager.AcceptableClasses = {
	BillboardGui = true,
	CanvasGroup = true,
	Frame = true,
	ImageButton = true,
	ImageLabel = true,
	ScrollingFrame = true,
	ScreenGui = true,
	SurfaceGui = true,
	TextBox = true,
	TextButton = true,
	TextLabel = true,
	UIAspectRatioConstraint = true,
	UICorner = true,
	UIFlexItem = true,
	UIGradient = true,
	UIGridLayout = true,
	UIListLayout = true,
	UIPadding = true,
	UIPageLayout = true,
	UIScale = true,
	UISizeConstraint = true,
	UIStroke = true,
	UITableLayout = true,
	UITextSizeConstraint = true,
	VideoFrame = true,
	ViewportFrame = true,
}

for screen: ScreenGui in playerGui:GetChildren() do
	UIManager.Screens[screen.Name] = {}
	for _, child: Instance in screen:GetDescendants() do
		if not UIManager.AcceptableClasses[child.ClassName] then
			continue
		end

		if
			child:IsA("UIStroke")
			or child:IsA("UIGradient")
			or child:IsA("UIScale")
			or child:IsA("UICorner")
			or child:IsA("UIAspectRatioConstraint")
			or child:IsA("UISizeConstraint")
			or child:IsA("UITextSizeConstraint")
			or child:IsA("UIListLayout")
			or child:IsA("UIGridLayout")
			or child:IsA("UITableLayout")
			or child:IsA("UIPageLayout")
			or child:IsA("UIPadding")
			or child:IsA("UIFlexItem")
		then
			UIManager.Screens[screen.Name][child.Parent.Name .. "." .. child.Name] = child
		else
			UIManager.Screens[screen.Name][child.Name] = child
		end
	end
end

for _, controller in script.Parent.Controllers:GetChildren() do
	if controller:IsA("ModuleScript") then
		UIManager.Controllers[controller.Name] = require(controller)
	end
end

function UIManager:CreateUI(screenName, name, class, parent, properties)
	if UIManager.Screens[screenName][name] then
		warn("Duplicate Name Exists In", screenName)
		return
	end

	if not UIManager.AcceptableClasses[class] then
		warn("Class:", class, "is not an acceptable Class")
		return
	end

	local ui = Instance.new(class)
	if not ui then
		warn("Class:", class, "is Invalid")
		return
	end

	local parentInstance = UIManager.Screens[screenName][parent]
	if not parentInstance or not parentInstance:IsA("Instance") then
		warn("Parent:", parent, "doesn't exist or isn't an Instance")
		return
	end

	ui.Name = name
	ui.Parent = parentInstance
	properties = typeof(properties) == "table" and properties or {}
	print(properties)

	for property, value in pairs(properties) do
		local _, error = pcall(function()
			ui[property] = value
		end)
		if error then
			warn("Property or Value is invalid")
			continue
		end
	end
	UIManager.Screens[screenName][name] = ui
    return UIManager.Screens[screenName][name]
end

function UIManager:DestroyUI(screenName, name)
	if UIManager.Screens[screenName][name] then
		if UIManager.Screens[screenName][name]:IsA("Instance") then
			UIManager.Screens[screenName][name]:Destroy()
		end
		UIManager.Screens[screenName][name] = nil
	end
end

function UIManager:GetUI(screenName, name)
	if UIManager.Screens[screenName] and UIManager.Screens[screenName][name] then
		return UIManager.Screens[screenName][name]
	end
	return
end

return UIManager
