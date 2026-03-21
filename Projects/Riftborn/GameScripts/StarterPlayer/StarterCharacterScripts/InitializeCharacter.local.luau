local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterModule = ModuleLoader:Load("Client", "Character")
CharacterModule:Init()
