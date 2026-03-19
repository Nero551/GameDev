local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MainMenuController = {}

local UIHelper = require(ReplicatedStorage.Modules.UI.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.UI.UIManager)
local player = Players.LocalPlayer

return MainMenuController