local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIFactory = require(ReplicatedStorage.Modules.UI.Utilities.UIFactory)
local Button = {}

function Button:Create(name,parent)
    UIFactory:Create(name, "ImageButton", parent, {})
end

return Button