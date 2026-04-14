local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ThemeData = require(ReplicatedStorage.Modules.Data.ThemeData)
local DataService = require(ServerScriptService.Services.Core.DataService)
local ThemeService = {}

function ThemeService:UpdateTheme(player)
	local Theme = DataService:GetTable(player, "Settings").Theme
	local config = player:FindFirstChild("Settings"):FindFirstChild("Theme")
	if Theme.Selected == "Custom" then
		Theme.Custom = Theme.Custom or ThemeData.Default
		for catagory, tbl in Theme.Custom do
			if typeof(tbl) == "table" then
				for type, v in pairs(tbl) do
					config:SetAttribute(catagory .. "_" .. type, v)
				end
			else
				config:SetAttribute(catagory, tbl)
			end
		end
	else
		if ThemeData[Theme.Selected] then
			for catagory, tbl in ThemeData[Theme.Selected] do
				if typeof(tbl) == "table" then
					for type, v in pairs(tbl) do
						config:SetAttribute(catagory .. "_" .. type, v)
					end
				else
					config:SetAttribute(catagory, tbl)
				end
			end
		else
			Theme.Selected = nil
		end
	end
end

function ThemeService:SetupThemes(player)
	local config = player:FindFirstChild("Settings"):FindFirstChild("Theme")
	if not config then
		config = Instance.new("Configuration")
		config.Name = "Theme"
		config.Parent = player.Settings
	end
	ThemeService:UpdateTheme(player)
end

function ThemeService:ChangeTheme(player, wantedTheme)
	local Theme = DataService:GetTable(player, "Settings").Theme
	if ThemeData[wantedTheme] then
		Theme.Selected = Theme
		if wantedTheme == "Custom" then
			Theme.Custom = Theme.Custom or ThemeData.Default
		end
		ThemeService:UpdateTheme(player)
	end
end

function ThemeService:ModifyCustomTheme(player, catagory, type, color)
	local Theme = DataService:GetTable(player, "Settings").Theme

	if typeof(Color3) == "Color3" then
		if Theme[catagory] then
			if Theme[catagory][type] then
				Theme[catagory][type] = color
			else
				if typeof(Theme[catagory]) == "Color3" then
					Theme[catagory] = color
				end
			end
		end
	end
	ThemeService:UpdateTheme(player)
end

return ThemeService
