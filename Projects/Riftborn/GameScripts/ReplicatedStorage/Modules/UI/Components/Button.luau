local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIFactory = require(ReplicatedStorage.Modules.UI.Utilities.UIFactory)
local UIHelper = require(ReplicatedStorage.Modules.UI.Utilities.UIHelper)
local Button = {}

local xd = Instance.new("TextLabel")

function Button:Create(name,parent)
    UIFactory:Create(name, "ImageButton", parent, {
        Size = UDim2.fromScale(0.05,0.025),
        Image = "rbxassetid://114281700012249",
        KeepAspectRatio = true
    })

    UIFactory:Create(name..".RGBStroke", "ImageLabel", name, {
        Size = UDim2.fromScale(1, 1),
        Image = "rbxassetid://120204715805520",
        KeepAspectRatio = true
    })

    UIFactory:Create("RGBStroke.UIGradient", "UIGradient", name..".RGBStroke", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(138,184,255)),
            ColorSequenceKeypoint.new(0.325, Color3.fromRGB(178,140,255)),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(106,125,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(138,184,255))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.25),
            NumberSequenceKeypoint.new(1, 0.25),
        }),
        Rotation = 90,
    })
    UIHelper:RotateGradient("RGBStrokeUIGradient")
end

return Button