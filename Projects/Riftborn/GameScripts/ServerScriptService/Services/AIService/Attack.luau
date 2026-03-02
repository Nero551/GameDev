return function(npc)
	local AIService = require(script.Parent)
	local CombatService = require(script.Parent.Parent.CombatService)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end

	AIService:AcquireTarget(npc)
	if not AIData.Target then return end
	
	AIData.Humanoid:MoveTo(AIData.Target.Position)
	CombatService:Attack(npc, AIData.Tool, nil, AIData.Damage)
end