local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
return function(npc)
	local AIService = ModuleLoader:Load("Server", "AIService")
	local CombatService = ModuleLoader:Load("Server", "CombatService")
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	AIData.LastAttackSeenTime = 0
	CombatService:Block(npc, false, AIData.Tool)
end
