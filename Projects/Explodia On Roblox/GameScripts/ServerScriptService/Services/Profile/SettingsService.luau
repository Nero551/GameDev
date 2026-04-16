local KeybindsService = require(script.Parent.KeybindsService)
local ThemeService = require(script.Parent.ThemeService)
local SettingsService = {}

function SettingsService:SetupSettings(player)
    local folder = player:FindFirstChild("Settings")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Settings"
        folder.Parent = player
    end


    KeybindsService:SetupKeybinds(player)
    ThemeService:SetupThemes(player)
end

return SettingsService