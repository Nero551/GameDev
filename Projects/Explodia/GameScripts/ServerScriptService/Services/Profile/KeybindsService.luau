local ServerScriptService = game:GetService("ServerScriptService")
local DefualtPlayerData = require(ServerScriptService.Modules.DefualtPlayerData)
local DataService = require(ServerScriptService.Services.Core.DataService)
local KeybindsService = {}

function KeybindsService:SetupKeybinds(player)
	local Keybinds = DataService:GetTable(player, "Keybinds")
    local config = player:FindFirstChild("Keybinds")
    if not config then
        config = Instance.new("Configuration")
        config.Name = "Keybinds"
        config.Parent = player
    end

    for keybind,key in pairs(DefualtPlayerData.Keybinds) do
        if not Keybinds[keybind] then
            Keybinds[keybind] = key
        end
    end

    for keybind,key in pairs(Keybinds) do
        if not DefualtPlayerData.Keybinds[keybind] then
            Keybinds[keybind] = nil
        end
        config:SetAttribute(keybind,key)     
    end
end

function KeybindsService:ChangeKeybind(player,keybind, key)
    local Keybinds = DataService:GetTable(player, "Keybinds")
	local config = player:FindFirstChild("Keybinds")
    if not config then
        KeybindsService:SetupKeybinds(player)
    end

    if Keybinds[keybind] then
        Keybinds[keybind] = key
        config:SetAttribute(keybind,key)
    end
end

return KeybindsService