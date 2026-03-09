local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DefaultProperties = require(ReplicatedStorage.Modules.UI.DefaultProperties)
local player = Players.LocalPlayer

local UIFactory = {}

UIFactory.UI = {}

function UIFactory:Create(name, class, parent, properties)
	---Making UI---
	local ui = Instance.new(class)
	if not ui then
		warn("Invalid Class:", class)
		return
	end
	ui.Name = name

	---Setting Parent---
	if class == "ScreenGui" then
		ui.Parent = player:WaitForChild("PlayerGui")
	elseif UIFactory.UI[parent] then
		ui.Parent = UIFactory.UI[parent]
	else
		warn("Invalid Parent:", parent)
	end
	---Setting Properties---
	for property, value in pairs(( DefaultProperties[class] or {})) do
		pcall(function()
			ui[property] = value
		end)
	end

	for property, value in pairs((properties or {})) do
		local success, err = pcall(function()
			ui[property] = value
		end)
		if not success then
			warn("Failed to set property:", property, err)
		end
	end

	UIFactory.UI[name] = ui
	print(UIFactory.UI)
	return UIFactory.UI[name]
end

function UIFactory:Get(name)
	return UIFactory.UI[name]
end

function UIFactory:Destroy(name)
	if UIFactory.UI[name] then
		UIFactory.UI[name]:Destroy()
		UIFactory.UI[name] = nil
	end
end

function UIFactory:ModifyProperty(name, properties)
	local ui = UIFactory.UI[name]
	if not ui then
		warn("Invalid UI:", name)
		return
	end
	if properties and typeof(properties) == "table" then
		for property, value in pairs(properties) do
			local success, err = pcall(function()
				ui[property] = value
			end)
			if not success then
				warn("Failed to set property:", property, err)
			end
		end
	else
		warn("Properties isn't a table or is equal nil.")
	end
end

return UIFactory
