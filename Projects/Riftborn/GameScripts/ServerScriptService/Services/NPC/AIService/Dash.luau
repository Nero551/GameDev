local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
return function(npc)
	
	local MovementService = ModuleLoader:Load("Server", "MovementService")
	local AIService = ModuleLoader:Load("Server", "AIService")
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	if not AIData.Target then return end
	AIData.Humanoid:MoveTo(AIData.Target.Position)
	MovementService:Dash(nil,AIData.Root.CFrame.LookVector, false, AIData.Target.Parent, npc)
end
