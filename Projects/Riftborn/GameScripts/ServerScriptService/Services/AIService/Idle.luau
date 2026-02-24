return function(npc)
	local AIService = require(script.Parent)
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	local humanoid:Humanoid = npc:WaitForChild("Humanoid")

	humanoid.WalkSpeed = 0
	
	if AIData.RunAnimation.IsPlaying then
		AIData.RunAnimation:Stop()
	end
	
	if AIData.WalkAnimation.IsPlaying then
		AIData.WalkAnimation:Stop()
	end
	
	if not AIData.IdleAnimation.IsPlaying then
		AIData.IdleAnimation:Play()
	end
end