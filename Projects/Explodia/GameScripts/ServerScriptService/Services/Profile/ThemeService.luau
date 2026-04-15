local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ThemeData = require(ReplicatedStorage.Modules.Data.ThemeData)
local DataService = require(ServerScriptService.Services.Core.DataService)
local ThemeService = {}


--? require(game.ServerScriptService.Services.Profile.ThemeService):ChangeMainThemeWhileInStudio()
function ThemeService:ChangeMainThemeWhileInStudio()
	for _, ui in CollectionService:GetTagged("Stroke") do
		if ui:IsA("UIStroke") then
			ui.Color = ThemeData.Default.Stroke
		end
		if ui:IsA("ImageLabel") then
			ui.ImageColor3 = ThemeData.Default.Stroke
		end
	end

	for _, ui in CollectionService:GetTagged("Surface_Panel") do
		ui.BackgroundColor3 = ThemeData.Default.Surface.Panel
	end

	for _, ui in CollectionService:GetTagged("Surface_SubPanel") do
		ui.BackgroundColor3 = ThemeData.Default.Surface.SubPanel
	end

	for _, ui in CollectionService:GetTagged("Surface_Background") do
		ui.BackgroundColor3 = ThemeData.Default.Surface.Background
	end

	for _, ui in CollectionService:GetTagged("Text_Background") do
		ui.BackgroundColor3 = ThemeData.Default.Text.Background
	end

	for _, ui in CollectionService:GetTagged("Text_Primary") do
		ui.BackgroundColor3 = ThemeData.Default.Text.Primary
	end

	for _, ui in CollectionService:GetTagged("Button_Background") do
		ui.BackgroundColor3 = ThemeData.Default.Button.Background
	end
end

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
