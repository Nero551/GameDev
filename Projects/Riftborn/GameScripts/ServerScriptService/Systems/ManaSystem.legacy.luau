---ManaSystem---
local  players = game:GetService("Players")
local runService = game:GetService("RunService")
local repstor = game:GetService("ReplicatedStorage")
local remotes =   repstor.Remotes
local ManaService = require(script.Parent.Parent.ServerModules.ManaService)


runService.Heartbeat:Connect(function(dt)
	ManaService:ManaRegen(dt)
end)



