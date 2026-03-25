return function(npc)
	local AIService = require(game.ServerScriptService.Services.NPC.AIService)
	local CombatService = require(game.ServerScriptService.Services.Combat.CombatService)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	AIData.LastAttackSeenTime = 0
	CombatService:Block(npc, 0)
end
