return function(npc)
	local AIService = require(game.ServerScriptService.Services.NPC.AIService)
	local AIData = AIService.ActiveAIs[npc]
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	if not AIData then
		return
	end

	VitalsService:ModifyVital(npc, "Movement", "ModifyWalkSpeed", {
		["WalkSpeed"] = AIData.WalkSpeed,
	})
	if not AIData.WalkAnimation.IsPlaying then
		AIData.WalkAnimation:Play()
	end

	if not AIData.WanderTarget then
		local radius = AIData.WanderRadius
		AIData.WanderTarget = Vector3.new(math.random(-radius, radius), 0, math.random(-radius, radius))
		AIData.Humanoid:MoveTo(AIData.WanderTarget)
	end

	if (AIData.Root.Position - AIData.WanderTarget).Magnitude < 3 then
		AIData.WalkAnimation:Stop()
		if not AIData.IdleAnimation.IsPlaying then
			AIData.IdleAnimation:Play()
		end
		task.delay(2, function()
			AIData.WanderTarget = nil
		end)
	end
end
