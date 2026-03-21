local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MovementConfig = require(ReplicatedStorage.Modules.Configs.MovementConfig)
local ActionVerifier = require(game.ReplicatedStorage.Modules.Helpers.ActionVerifier)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)
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
		local rayparams = RaycastParams.new()
		rayparams.FilterType = Enum.RaycastFilterType.Include	
		rayparams.FilterDescendantsInstances = {AIData.Target.Parent}

		local result = workspace:Raycast(AIData.Root.Position,
		 AIData.Root.CFrame.LookVector*MovementConfig.DashConfig.MaxDashDistance, rayparams)
		if result then
			return true
		end
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
	if not AIData.Abilities then return false end
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
	if not StateChecker:CheckState(AIData.Target.Parent, "Attacking") and
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
	if StateChecker:CheckState(AIData.Target.Parent, "Attacking") and
		distance <= AIData.AttackRange*1.5 and ActionVerifier:CanBlock(AIData.Humanoid.Parent) then
		return true
	end
	if StateChecker:CheckState(AIData.Target.Parent, "Casting") and ActionVerifier:CanBlock(AIData.Humanoid.Parent) then
		return true
	end
	return false
end

function CanDoAction:CanUnBlock(AIData)
	if not AIData then return false end
	if StateChecker:CheckState(AIData.Humanoid.Parent, "Blocking") and not
		StateChecker:CheckState(AIData.Target.Parent, "Attacking") and
		AIData.LastAttackSeenTime > 0 and os.clock() - AIData.LastAttackSeenTime > 0.5 then
		return true
	end
	return false
end

function CanDoAction:BlockBroken(AIData)
	if StateChecker:CheckState(AIData.Humanoid.Parent, "BlockBroken") then
		return true
	end
	return false
end

return CanDoAction
