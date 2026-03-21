local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerModule = ModuleLoader:Load("Client", "Player")
PlayerModule:Init()
