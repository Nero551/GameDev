local StateChecker = require(script.Parent.StateChecker)

local ActionVerifier = {}

function ActionVerifier:CanSprint(character)
	local humanoid = character:WaitForChild("Humanoid")
	if humanoid.MoveDirection.Magnitude >  0 then
		if not StateChecker:CheckState(character, "Attacking", "Blocking", "NoMove", "Stunned", "NoSprint", "BlockBroken") then
			return true
		end
	end
	return false
end

function ActionVerifier:CanWalk(character)
	local humanoid = character:WaitForChild("Humanoid")
	if humanoid.MoveDirection.Magnitude >  0 then
		if not StateChecker:CheckState(character, "Attacking", "NoMove", "Stunned", "NoSprint", "Sprinting", "BlockBroken") then
			return true
		end
	end
	return false
end

function ActionVerifier:CanAttack(character)
	if StateChecker:CheckState(character , "Attacking" , "Blocking", "Stunned", "NoPunch"
		, "Dashing", "FlashStep", "FlashStepEndLag" ,"DashEndLag", "Casting", "Frozen", "BlockBroken", "ComboCooldown") then
		return false
	end
	return true
end


function ActionVerifier:CanBlock(character)
	if StateChecker:CheckState(character, "Stunned", "Attacking", "NoBlock", "Flashstep", "Dashing",
		"FlashStepEndLag" ,"DashEndLag", "Frozen", "BlockBroken") then
		return false
	end
	return true
end


function ActionVerifier:CanAbility(character, abilityLetter)
	if StateChecker:CheckState(character, "Stunned", "Attacking", "Dashing",
		"Flashstep", "Blocking", "Frozen","FlashStepEndLag" ,"DashEndLag", "Frozen", "BlockBroken") then
		return false
	end
	
	if abilityLetter and StateChecker:CheckState(character, "Ability"..abilityLetter.. " Cooldown") then
		return false
	end
	
	return true
end


function ActionVerifier:CanDash(character)
	if StateChecker:CheckState(character,"Stunned", "Blocking", "Attacking", "NoMove", "Dashing",
		"DashCoolDown", "FlashStep", "Frozen", "BlockBroken") then
		return false
	end
	return true
end


function ActionVerifier:CanFlashstep(character, flashstepCharge)
	if StateChecker:CheckState(character,"Stunned", "Blocking", "Attacking", "NoMove", "Dashing",
		"FlashStepEndLag", "FlashStep", "Frozen", "BlockBroken") or flashstepCharge == 0 then
		return false
	end
	return true
end


function ActionVerifier:CanWallRun(character:Model)
	local hrp = character:WaitForChild("HumanoidRootPart")
	local Right = hrp.CFrame.RightVector * 2
	local Left = -hrp.CFrame.RightVector * 2
	Left = Vector3.new(Left.X, 0 , Left.Z)
	Right = Vector3.new(Right.X, 0 , Right.Z)
	if not StateChecker:CheckState(character,"Stunned", "Blocking", "Attacking", "NoMove", "Dashing",
		 "WallJump","WallRunning", "FlashStep", "FlashStepEndLag", "Frozen", "BlockBroken") then	
		
		local rayparams = RaycastParams.new()
		rayparams.FilterType = Enum.RaycastFilterType.Exclude
		rayparams.FilterDescendantsInstances = {character}
		local rayresult = workspace:Raycast(hrp.Position, Right, rayparams)
		
		if rayresult then
			return true
		end
		rayresult = workspace:Raycast(hrp.Position,Left, rayparams)
		if rayresult then
			return true
		end
	end
	return false
end

return ActionVerifier
