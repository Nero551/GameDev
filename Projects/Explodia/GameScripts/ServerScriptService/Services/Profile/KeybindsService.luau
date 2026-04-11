local ServerScriptService = game:GetService("ServerScriptService")
local DefualtPlayerData = require(ServerScriptService.Modules.DefualtPlayerData)
local DataService = require(ServerScriptService.Services.Core.DataService)
local KeybindsService = {}

function KeybindsService:SetupKeybinds(player)
	local Keybinds = DataService:GetTable(player, "Settings").Keybinds
	local config = player:FindFirstChild("Settings"):FindFirstChild("Keybinds")
	if not config then
		config = Instance.new("Configuration")
		config.Name = "Keybinds"
		config.Parent = player.Settings
	end

	for keybind, key in pairs(DefualtPlayerData.Settings.Keybinds) do
		if not Keybinds[keybind] then
			Keybinds[keybind] = key
		end
	end
	
	for keybind, key in pairs(Keybinds) do
		if not DefualtPlayerData.Settings.Keybinds[keybind] then
			Keybinds[keybind] = nil
		end
		config:SetAttribute(keybind, key)
	end
end

function KeybindsService:ChangeKeybind(player, keybind, key)
	local Keybinds = DataService:GetTable(player, "Settings").Keybinds
	local config = player:FindFirstChild("Settings"):FindFirstChild("Keybinds")
	if not config then
		KeybindsService:SetupKeybinds(player)
	end

	if Keybinds[keybind] then
		Keybinds[keybind] = key
		config:SetAttribute(keybind, key)
	end
end

return KeybindsService
