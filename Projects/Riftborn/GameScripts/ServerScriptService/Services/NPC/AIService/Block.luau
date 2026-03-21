return function(npc)
	local AIService = require(script.Parent)
	local CombatService = require(game.ServerScriptService.Services.Combat.CombatService)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end

	AIService:AcquireTarget(npc)
	if not AIData.Target then return end
	
	AIData.LastAttackSeenTime = os.clock()
	
	CombatService:Block(npc, true, AIData.Tool)
end
