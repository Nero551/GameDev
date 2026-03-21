local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UIManager = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

UIManager.ActiveScreen = "HUD"
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

function UIManager:WaitForLoad()
	repeat
		task.wait()
	until #playerGui:GetDescendants() >= #StarterGui:GetDescendants()
	task.wait(0.25)
end

function UIManager:Init()
	UIManager:WaitForLoad()
	for _, screen in playerGui:GetChildren() do
		if screen:IsA("ScreenGui") then
			UIManager.Screens[screen.Name] = {}
			for _, child in screen:GetDescendants() do
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
					continue
				else
					if UIManager.Screens[screen.Name][child.Name] then
						warn("Duplicate Name Exists For:",child.Name)
					end
					UIManager.Screens[screen.Name][child.Name] = child
				end
			end
		end
	end

	for _, controller in script.Parent.Controllers:GetChildren() do
		if controller:IsA("ModuleScript") then
			UIManager.Controllers[controller.Name] = require(controller)
		end
	end

	for _, controller in UIManager.Controllers do
		for _, value in controller do
			if typeof(value) == "function" then
				value(controller)
			end
		end
	end
	print("Controllers:", UIManager.Controllers)
	print("Screens:", UIManager.Screens)
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
	if not parentInstance then
		warn("Parent:", parent, "doesn't exist")
		return
	end

	properties = typeof(properties) == "table" and properties or {}
	for property, value in pairs(properties) do
		local _, error = pcall(function()
			ui[property] = value
		end)
		if error then
			warn("Property or Value is invalid")
			continue
		end
	end

	ui.Name = name
	ui.Parent = parentInstance

	UIManager.Screens[screenName][name] = ui
	return UIManager.Screens[screenName][name]
end

function UIManager:CloneUI(screenName,name,ui,parentName)
	if UIManager.Screens[screenName] then
		local parentInstance = UIManager.Screens[screenName][parentName]
		if not parentInstance then 
			return
		end
		local clone:Instance = ui:Clone()
		clone.Parent = parentInstance
		clone.Name = name
		UIManager.Screens[screenName][name] = clone
		return clone
	end
	return
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
	warn("UI:", name, "Doesn't Exist", { debug.traceback() })
	return
end

function UIManager:GetScreen(screenName)
	if UIManager.Screens[screenName] then
		local screen = playerGui:FindFirstChild(screenName)
		if screen then
			return screen
		end
	end
	return warn("Screen Doesn't Exist")
end

function UIManager:SetActiveScreen(screenName)
	if UIManager.Screens[screenName] then
		UIManager.ActiveScreen = screenName
	end
	print(UIManager.ActiveScreen, {debug.traceback()})
end

return UIManager
