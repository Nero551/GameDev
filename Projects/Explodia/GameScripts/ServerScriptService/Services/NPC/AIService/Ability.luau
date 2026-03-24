return function(npc)
	local AIService = require(game.ServerScriptService.Services.NPC.AIService)
	local AbilityService = require(game.ServerScriptService.Services.Combat.AbilityService)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end

	AIService:AcquireTarget(npc)
	if not AIData.Target then return end
	if not AIData.ChosenAbility then return end
	AbilityService:UseAbility(nil, npc, AIData.Tool,nil,nil, AIData.ChosenAbility , AIData.Damage)
end
