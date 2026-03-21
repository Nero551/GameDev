local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
return function(npc)
	local AIService = ModuleLoader:Load("Server", "AIService")
	local CombatService = ModuleLoader:Load("Server", "CombatService")
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end

	AIService:AcquireTarget(npc)
	if not AIData.Target then return end
	
	AIData.Humanoid:MoveTo(AIData.Target.Position)
	CombatService:Attack(npc, AIData.Tool, nil, AIData.Damage)
end
