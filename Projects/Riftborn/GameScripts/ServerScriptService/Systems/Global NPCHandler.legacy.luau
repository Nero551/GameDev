local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local NPCService = require(ServerScriptService.Services.NPCService)
local AIService = require(script.Parent.Parent.Services.AIService)

for _,NPC in workspace.World.Live.ActiveNPCS:GetDescendants() do
	if NPC:IsA("Model") then
		NPCService:RegisterNPC(NPC)
	end
end

workspace.World.Live.ActiveNPCS.DescendantAdded:Connect(function(descendant)
	NPCService:RegisterNPC(descendant)
end)

workspace.World.Live.ActiveNPCS.DescendantRemoving:Connect(function(descendant)
	NPCService:UnRegisterNPC(descendant)
end)

local updateRate = 0.05
local elapsed = 0

RunService.Heartbeat:Connect(function(dt)
elapsed =  elapsed + dt
	if elapsed < updateRate then return end
	elapsed = 0
	
	for npc,AIData in AIService.ActiveAIs do
		AIService.Brains[AIData.Type.."Brain"](npc)
	end
end)