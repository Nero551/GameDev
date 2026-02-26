return function(npc)
	
	local MovementService = require(script.Parent.Parent.MovementService)
	local AIService = require(script.Parent)
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	if not AIData.Target then return end
	
	MovementService:FlashStep(npc)
end