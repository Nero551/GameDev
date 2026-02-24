
local ActionVerifier = require(game.ReplicatedStorage.Modules.ActionVerifier)
local StateService = require(game.ReplicatedStorage.Modules.StateService)
local CanDoAction = {}

function CanDoAction:CanRun(AIData)
	if not AIData then return false end
	if not AIData.Target then return false end
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
		
	if distance <= AIData.DetectionRange then
		return true
	end
	return false
end

function CanDoAction:CanAttack(AIData)
	if not AIData then return false end
	if not AIData.Target then return false end
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
	if distance <= AIData.AttackRange and ActionVerifier:CanAttack(AIData.Humanoid.Parent) then
		return true
	end
	return false
end

function CanDoAction:CanBlock(AIData)
	if not AIData then return false end
	if not AIData.Target then return false end
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
	if StateService.checkState(AIData.Target.Parent, "Attacking") and
		distance <= AIData.AttackRange and ActionVerifier:CanBlock(AIData.Humanoid.Parent) then
		return true
	end
	return false
end

function CanDoAction:CanUnBlock(AIData)
	if not AIData then return false end
	if StateService.checkState(AIData.Humanoid.Parent, "Blocking") and not
		StateService.checkState(AIData.Target.Parent, "Attacking") and
		AIData.LastAttackSeenTime > 0 and os.clock() - AIData.LastAttackSeenTime > 0.25 then
		return true
	end
	return false
end

function CanDoAction:BlockBroken(AIData)
	if StateService.checkState(AIData.Humanoid.Parent, "BlockBroken") then
		return true
	end
	return false
end


return CanDoAction
