return function(npc)
	local AIService = require(game.ServerScriptService.Services.NPC.AIService)
	local CombatService = require(game.ServerScriptService.Services.Combat.CombatService)

	local AIData = AIService.ActiveAIs[npc]
	if not AIData then
		return
	end

	AIService:AcquireTarget(npc)
	if not AIData.Target then
		return
	end

	AIData.LastAttackSeenTime = os.clock()

	CombatService:Block(npc, 1)
end
