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

	if AIData.WanderTarget then
		if (AIData.Root.Position - AIData.WanderTarget).Magnitude <= 10 then
			if AIData.WalkAnimation.IsPlaying then
				AIData.WalkAnimation:Stop()
			end
			if not AIData.IdleAnimation.IsPlaying then
				AIData.IdleAnimation:Play()
			end

			task.delay(4, function()
				AIData.WanderTarget = nil
			end)
		else
			if AIData.IdleAnimation.IsPlaying then
				AIData.IdleAnimation:Stop()
			end
			if not AIData.WalkAnimation.IsPlaying then
				AIData.WalkAnimation:Play()
			end
			AIData.Humanoid:MoveTo(AIData.WanderTarget)
		end
	else
		local radius = AIData.WanderRadius
		local offset = Vector3.new(math.random(-radius, radius), 0, math.random(-radius, radius))
		AIData.WanderTarget = AIData.Root.Position + offset
	end
end
