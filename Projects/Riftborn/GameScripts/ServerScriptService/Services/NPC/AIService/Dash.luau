return function(npc)
	
	local MovementService = require(game.ServerScriptService.Services.Combat.MovementService)
	local AIService = require(script.Parent)
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	if not AIData.Target then return end
	AIData.Humanoid:MoveTo(AIData.Target.Position)
	MovementService:Dash(nil,AIData.Root.CFrame.LookVector, false, AIData.Target.Parent, npc)
end
