local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local ServerScriptService = game:GetService("ServerScriptService")
local CharacterVitalsService = ModuleLoader:Load("Server", "CharacterVitalsService")
local CanDoAction = ModuleLoader:Load("Server", "CanDoAction")
return function(npc)
    local AIService = ModuleLoader:Load("Server", "AIService")
    
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	AIService:AcquireTarget(npc)

	if CharacterVitalsService:GetVital(npc, "Health").CurrentHealth <= 0 then
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

	if CanDoAction:CanAbility(AIData) then
		AIData.State = "Ability"
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
