local players = game:GetService("Players")
local char = script.Parent
local playerStateHandler = require(game.ReplicatedStorage.Modules.Client.PlayerStateHandler)

playerStateHandler(char)
