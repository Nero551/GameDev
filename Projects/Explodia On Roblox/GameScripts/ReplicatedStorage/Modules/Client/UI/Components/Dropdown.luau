local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClickHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.ClickHelper)
local HoverHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.HoverHelper)
return function(frame)
    local toggleButton:TextButton = frame:FindFirstChild("ToggleButton")
    local dropdown:Frame = frame:FindFirstChild("Dropdown")
    local state = 0
    ClickHelper:ClickEffects(toggleButton)
    HoverHelper:HoverEffects(toggleButton)

    toggleButton.MouseButton1Click:Connect(function()
        if state == 1 then
            state = 0
            dropdown.Visible = false
        else
            state = 1
            dropdown.Visible = true
        end
    end)
end
