local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
return function(frame)
    local toggleButton:TextButton = frame:FindFirstChild("ToggleButton")
    local dropdown:Frame = frame:FindFirstChild("Dropdown")
    local state = 0
    UIHelper:ClickEffects(toggleButton)
    UIHelper:HoverEffects(toggleButton)

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
