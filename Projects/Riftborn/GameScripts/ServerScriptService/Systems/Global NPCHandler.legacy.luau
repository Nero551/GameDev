local RunService = game:GetService("RunService")
local repstor = game:GetService("ReplicatedStorage")

local stateService = require(repstor.Modules.StateService)
local AIService = require(script.Parent.Parent.Services.AIService)


local updateRate = 0.05
local elapsed = 0

RunService.Heartbeat:Connect(function(dt)
	elapsed =  elapsed + dt
	if elapsed < updateRate then return end
	elapsed = 0
	
	for npc,AIData in AIService.ActiveAIs do
		AIService:EnemyBrain(npc)
	end
end)