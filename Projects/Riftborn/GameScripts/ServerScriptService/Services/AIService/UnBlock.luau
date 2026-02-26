return function(npc)
	local AIService = require(script.Parent)
	local CombatService = require(script.Parent.Parent.CombatService)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	AIData.LastAttackSeenTime = 0
	CombatService:Block(npc, false, AIData.Tool)
end