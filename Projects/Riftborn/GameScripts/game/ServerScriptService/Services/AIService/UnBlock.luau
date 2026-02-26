return function(npc)
	local AIService = require(script.Parent)
	local CombatService = require(script.Parent.Parent.CombatService)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	local humanoid:Humanoid = npc:WaitForChild("Humanoid")
	AIData.LastAttackSeenTime = 0
	CombatService:Block(npc, false, AIData.Tool)
end