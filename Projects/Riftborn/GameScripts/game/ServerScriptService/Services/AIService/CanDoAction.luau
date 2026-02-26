
local ActionVerifier = require(game.ReplicatedStorage.Modules.ActionVerifier)
local StateService = require(game.ReplicatedStorage.Modules.StateService)
local CharacterVitalsService = require(script.Parent.Parent.CharacterVitalsService)
local CanDoAction = {}

function CanDoAction:CanRun(AIData)
	if not AIData then return false end
	if not AIData.Target then return false end
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
		
	if distance <= AIData.DetectionRange and AIData.Humanoid.WalkSpeed > 0 then
		return true
	end
	return false
end

function CanDoAction:CanDash(AIData)
	if not AIData then return false end
	if not AIData.Target then return false end
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
	if distance <= AIData.DetectionRange and distance >= AIData.DetectionRange/2 and
		ActionVerifier:CanDash(AIData.Humanoid.Parent) then
		return true
	end	
	return false
end

function CanDoAction:CanFlashstep(AIData)
	if not AIData then return false end
	if not AIData.Target then return false end
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
	if distance <= AIData.DetectionRange and distance >= AIData.DetectionRange/2 and 
		ActionVerifier:CanFlashstep(AIData.Humanoid.Parent,
			CharacterVitalsService:GetVital(AIData.Humanoid.Parent, "FlashStep").CurrentFlashStep) then
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

function CanDoAction:CanAbility(AIData)
	if not AIData then return false end
	if not AIData.Target then return false end
	local highestDamage = 0
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
	
	for letter,AbilityData in  AIData.Abilities do
		if distance <= (math.abs(AbilityData.HitBoxPosition.Z) + (AbilityData.HitBoxSize.Z/2)) and 
			ActionVerifier:CanAbility(AIData.Humanoid.Parent, letter) then
			if AbilityData.Damage * (AbilityData.Hits or 1) > highestDamage then
				highestDamage = AbilityData.Damage * (AbilityData.Hits or 1)
				AIData.ChosenAbility  = letter
			end
		end	
	end
	
	local ability = AIData.Abilities[AIData.ChosenAbility]
	if not ability then return false end
	if not StateService.checkState(AIData.Target.Parent, "Attacking") and
		ActionVerifier:CanAbility(AIData.Humanoid.Parent, AIData.ChosenAbility) and
		distance <= (math.abs(ability.HitBoxPosition.Z) + (ability.HitBoxSize.Z/2)) then
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
