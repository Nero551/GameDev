return function(npc)
	local AIService = require(game.ServerScriptService.Services.NPC.AIService)
	local TechniqueService = require(game.ServerScriptService.Services.Combat.TechniqueService)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end

	AIService:AcquireTarget(npc)
	if not AIData.Target then return end
	if not AIData.ChosenTechnique then return end
	TechniqueService:UseTechnique(npc, AIData.ChosenTechnique)
end
