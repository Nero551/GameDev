return function(npc)
	local AIService = require(game.ServerScriptService.Services.NPC.AIService)
	local CombatService = require(game.ServerScriptService.Services.Combat.CombatService)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end

	AIService:AcquireTarget(npc)
	if not AIData.Target then return end
	
	AIData.Humanoid:MoveTo(AIData.Target.Position)
	CombatService:Attack(npc, AIData.Tool, nil, AIData.Damage)
end
