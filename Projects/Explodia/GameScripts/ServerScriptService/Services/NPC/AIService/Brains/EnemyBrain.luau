local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
local CanDoAction = require(game.ServerScriptService.Services.NPC.AIService.CanDoAction)
return function(npc)
    local AIService = require(game.ServerScriptService.Services.NPC.AIService)
    
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	AIService:AcquireTarget(npc)

	if VitalsService:GetVital(npc, "Health").CurrentHealth <= 0 then
		AIData.State = "Dead"
		return
	end

	if not AIData.Target then
		AIData.State = "Idle"
		return
	end

	if CanDoAction:BlockBroken(AIData) then
		AIData.State = "BlockBroken" 
		return
	end

	if CanDoAction:CanUnBlock(AIData) then
		AIData.State = "UnBlock" 
		return
	end

	if CanDoAction:CanBlock(AIData) then
		AIData.State = "Block"
		return
	end

	if CanDoAction:CanTechnique(AIData) then
		AIData.State = "Technique"
		return
	end

	if CanDoAction:CanAttack(AIData) then
		AIData.State = "Attack" 
		return
	end

	if CanDoAction:CanFlashstep(AIData) then
		AIData.State = "Flashstep"
		return
	end

	if CanDoAction:CanDash(AIData) then
		AIData.State = "Dash"
		return
	end

	if CanDoAction:CanRun(AIData) then
		AIData.State = "Run"
		return
	end
end
