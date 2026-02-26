return function(npc)
	local AIService = require(script.Parent)
	local CombatService = require(script.Parent.Parent.CombatService)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	local humanoid:Humanoid = npc:WaitForChild("Humanoid")

	AIService:AcquireTarget(npc)
	if not AIData.Target then return end
	
	AIData.LastAttackSeenTime = os.clock()
	
	CombatService:Block(npc, true, AIData.Tool)
end