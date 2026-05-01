local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
return function(npc)
	local AIService = require(game.ServerScriptService.Services.NPC.AIService)

	local AIData = AIService.ActiveAIs[npc]
	if not AIData then
		return
	end
	AIService:AcquireTarget(npc)

	if VitalsService:GetVital(npc, "Health").CurrentHealth <= 0 then
		AIData.State = "Dead"
		return
	end

	if AIData.Target then
		AIData.State = "Idle"
		return
	end
	AIData.State = "Wander"
	return
end
