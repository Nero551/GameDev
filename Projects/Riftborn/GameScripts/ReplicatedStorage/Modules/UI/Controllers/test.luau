local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Button = require(ReplicatedStorage.Modules.UI.Components.Button)
local UIFactory = require(ReplicatedStorage.Modules.UI.Utilities.UIFactory)
local test = {}

UIFactory:Create("Screen", "ScreenGui")

Button:Create("Button", "Screen")

return test