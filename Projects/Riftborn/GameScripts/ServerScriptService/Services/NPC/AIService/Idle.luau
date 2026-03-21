local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
return function(npc)
	local AIService = ModuleLoader:Load("Server", "AIService")
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	
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
