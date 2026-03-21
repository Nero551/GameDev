local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
return function(npc)
	local AIService = ModuleLoader:Load("Server", "AIService")
	local AbilityService = ModuleLoader:Load("Server", "AbilityService")
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end

	AIService:AcquireTarget(npc)
	if not AIData.Target then return end
	if not AIData.ChosenAbility then return end
	AbilityService:UseAbility(nil, npc, AIData.Tool,nil,nil, AIData.ChosenAbility , AIData.Damage)
end
