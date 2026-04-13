local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TechniqueData = require(ReplicatedStorage.Modules.Data.TechniqueData)
local MovementConfig = require(game.ReplicatedStorage.Modules.Configs.MovementConfig)
local ActionVerifier = require(game.ReplicatedStorage.Modules.Helpers.ActionVerifier)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
local CanDoAction = {}

function CanDoAction:CanRun(AIData)
	if not AIData then
		return false
	end
	if not AIData.Target then
		return false
	end
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
	if distance <= AIData.DetectionRange and AIData.Humanoid.WalkSpeed > 0 and not AIData.Moving then
		return true
	end
	return false
end

function CanDoAction:CanDash(AIData)
	if not AIData then
		return false
	end
	if not AIData.Target then
		return false
	end
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
	if
		distance <= AIData.DetectionRange
		and distance >= AIData.DetectionRange / 2
		and ActionVerifier:CanDash(AIData.Humanoid.Parent)
	then
		local rayparams = RaycastParams.new()
		rayparams.FilterType = Enum.RaycastFilterType.Include
		rayparams.FilterDescendantsInstances = { AIData.Target.Parent }

		local result = workspace:Raycast(
			AIData.Root.Position,
			AIData.Root.CFrame.LookVector * MovementConfig.DashConfig.StudsPerSecond,
			rayparams
		)
		if result then
			return true
		end
	end
	return false
end

function CanDoAction:CanFlashstep(AIData)
	if not AIData then
		return false
	end
	if not AIData.Target then
		return false
	end
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
	if
		distance <= AIData.DetectionRange
		and distance >= AIData.DetectionRange / 2
		and ActionVerifier:CanFlashstep(
			AIData.Humanoid.Parent,
			VitalsService:GetVital(AIData.Humanoid.Parent, "FlashStep").CurrentFlashStep
		)
	then
		return true
	end
	return false
end

function CanDoAction:CanAttack(AIData)
	if not AIData then
		return false
	end
	if not AIData.Target then
		return false
	end
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
	if distance <= AIData.AttackRange and ActionVerifier:CanBasicAttack(AIData.Humanoid.Parent) then
		return true
	end
	return false
end

function CanDoAction:CanTechnique(AIData)
	if not AIData then
		return false
	end
	if not AIData.Techniques then
		return false
	end
	if not AIData.Target then
		return false
	end
	local highestDamage = 0
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude

	for slot, techniqueID in AIData.Techniques do
		local techniqueData = TechniqueData:GetTechniqueData(techniqueID)
		if
			distance <= (math.abs(techniqueData.HitBoxPosition.Z) + (techniqueData.HitBoxSize.Z / 2))
			and ActionVerifier:CanTechnique(AIData.Humanoid.Parent, techniqueID)
		then
			if (techniqueData.MinDamage + techniqueData.MaxDamage) / 2 * (techniqueData.Hits or 1) > highestDamage then
				highestDamage = (techniqueData.MinDamage + techniqueData.MaxDamage) / 2 * (techniqueData.Hits or 1)
				AIData.ChosenTechnique = slot
			end
		end
	end

	local techniqueID = AIData.Techniques[AIData.ChosenTechnique]
	if not techniqueID then
		return false
	end
	local techniqueData = TechniqueData:GetTechniqueData(techniqueID)
	if not techniqueData then
		return false
	end

	if
		not StateChecker:CheckState(AIData.Target.Parent, "Attacking")
		and ActionVerifier:CanTechnique(AIData.Humanoid.Parent, AIData.ChosenTechnique)
		and distance <= (math.abs(techniqueData.HitBoxPosition.Z) + (techniqueData.HitBoxSize.Z / 2))
	then
		return true
	end
	return false
end

function CanDoAction:CanBlock(AIData)
	if not AIData then
		return false
	end
	if not AIData.Target then
		return false
	end
	local distance = (AIData.Root.Position - AIData.Target.Position).Magnitude
	if
		StateChecker:CheckState(AIData.Target.Parent, "Attacking")
		and distance <= AIData.AttackRange * 1.5
		and ActionVerifier:CanBlock(AIData.Humanoid.Parent)
	then
		return true
	end
	if StateChecker:CheckState(AIData.Target.Parent, "Casting") and ActionVerifier:CanBlock(AIData.Humanoid.Parent) then
		return true
	end
	return false
end

function CanDoAction:CanUnBlock(AIData)
	if not AIData then
		return false
	end
	if
		StateChecker:CheckState(AIData.Humanoid.Parent, "Blocking")
		and not StateChecker:CheckState(AIData.Target.Parent, "Attacking")
		and AIData.LastAttackSeenTime > 0
		and os.clock() - AIData.LastAttackSeenTime > 0.5
	then
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
