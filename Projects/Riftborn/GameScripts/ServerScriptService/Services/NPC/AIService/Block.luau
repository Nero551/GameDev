local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
return function(npc)
	local AIService = ModuleLoader:Load("Server", "AIService")
	local CombatService = ModuleLoader:Load("Server", "CombatService")
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end

	AIService:AcquireTarget(npc)
	if not AIData.Target then return end
	
	AIData.LastAttackSeenTime = os.clock()
	
	CombatService:Block(npc, true, AIData.Tool)
end
