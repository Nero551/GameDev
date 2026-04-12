
--TODO MAKE CUSTOM PATHFINDING--
return function(npc)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local StateChecker = require(ReplicatedStorage.Modules.Helpers.StateChecker)
	local StateService = require(game.ServerScriptService.Services.Core.StateService)
	local AIService = require(game.ServerScriptService.Services.NPC.AIService)

	local AIData = AIService.ActiveAIs[npc]
	if not AIData then
		return
	end
	local humanoid: Humanoid = npc:WaitForChild("Humanoid")

	if not AIData.Target then
		return
	end

	if not StateChecker:CheckState(npc, "Sprinting") then
		StateService:AddState(npc, "Sprinting")
	end

	if AIData.IdleAnimation.IsPlaying then
		AIData.IdleAnimation:Stop()
	end

	if AIData.WalkAnimation.IsPlaying then
		AIData.WalkAnimation:Stop()
	end

	if not AIData.RunAnimation.IsPlaying then
		AIData.RunAnimation:Play()
	end

	humanoid:MoveTo(AIData.Target.Position)
end
