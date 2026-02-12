local StateService = require(script.Parent.StateService)

local ActionVerifier = {}

function ActionVerifier:CanAttack(character)
	if StateService.checkState(character , "Attacking" , "Blocking", "Stunned", "NoPunch"
		, "Dashing", "FlashStep", "FlashStepEndLag" ,"DashEndLag", "Casting") then
		return false
	end
	return true
end


function ActionVerifier:CanBlock(character)
	if StateService.checkState(character, "Stunned", "Attacking", "Blocking", "NoBlock", "Flashstep", "Dashing",
		"FlashStepEndLag" ,"DashEndLag") then
		return false
	end
	return true
end


function ActionVerifier:CanAbility(character, abilityLetter)
	if StateService.checkState(character, "Stunned", "Attacking", "Dashing",
		"Flashstep", "Blocking", "Ability"..abilityLetter.." Cooldown") then
		return false
	end
	return true
end


function ActionVerifier:CanDash(character)
	if StateService.checkState(character,"Stunned", "Blocking", "Attacking", "NoMove", "Dashing",
		"DashCoolDown", "FlashStep") then
		return false
	end
	return true
end


function ActionVerifier:CanFlashstep(character, flashstepCharge)
	if StateService.checkState(character,"Stunned", "Blocking", "Attacking", "NoMove", "Dashing",
		"FlashStepEndLag", "FlashStep") or flashstepCharge == 0 then
		return false
	end
	return true
end


function ActionVerifier:CanWallRun(character:Model)
	local hrp:Part? = character:WaitForChild("HumanoidRootPart")
	local Right = hrp.CFrame.RightVector * 2
	local Left = -hrp.CFrame.RightVector * 2
	Left = Vector3.new(Left.X, 0 , Left.Z)
	Right = Vector3.new(Right.X, 0 , Right.Z)
	if not StateService.checkState(character,"Stunned", "Blocking", "Attacking", "NoMove", "Dashing",
		 "WallJump","WallRunning", "FlashStep", "FlashStepEndLag") then	
		
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
	return 
end


function ActionVerifier:CanAirJump(character, AirJumpCharges)
	if StateService.checkState(character,"Stunned", "Blocking", "Attacking", "NoMove", "Dashing",
		"FlashStepEndLag", "FlashStep", "AirJump") or AirJumpCharges == 0 then
		 return false
	end
	return true
end

return ActionVerifier
