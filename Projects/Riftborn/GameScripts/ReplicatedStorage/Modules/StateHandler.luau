local starterGui = game:GetService("StarterGui")
local stateService = require(script.Parent.StateService)

local StateHandler = {}

local statePriority = {
	-- Highest priority: prevents all movement
	{Name = "Dead", WalkSpeed = 0, JumpPower = 0},
	{Name = "Stunned", WalkSpeed = 0, JumpPower = 0},
	{Name = "NoMove", WalkSpeed = 0, JumpPower = 0},
	{Name = "BlockBroken", WalkSpeed = 0, JumpPower = 0},
	{Name = "Dashing", WalkSpeed = 0, JumpPower = 0},
	{Name = "FlashStepEndLag", WalkSpeed = 0, JumpPower = 0},

	-- Combat-related movement limitations
	{Name = "Attacking", WalkSpeed = 10, JumpPower = 0},
	{Name = "Blocking", WalkSpeed = 7, JumpPower = 0},
	{Name = "NoSprint", WalkSpeed = 10, JumpPower = 0},   

	-- Special movement states
	{Name = "FlashStep", WalkSpeed = 64, JumpPower = 50},   
	{Name = "Sprinting", WalkSpeed = 32, JumpPower = 50}, 

}

function StateHandler:HandleStates(character:Model?)
	local humanoid = character:WaitForChild("Humanoid")
	
	------StateHandler------
	local finalWalkSpeed = 10 
	local finalJumpPower = 50 

	for _, stateInfo in ipairs(statePriority) do
		if stateService.checkState(character, stateInfo.Name) then
			finalWalkSpeed = stateInfo.WalkSpeed
			finalJumpPower = stateInfo.JumpPower
			break 
		end
	end
	
	if stateService.checkState(character,"FlashStep") then
		for _, trail:Trail? in character:GetDescendants() do
			if trail:IsA("Trail") and trail.Name == "SprintTrail" then
				trail.Enabled = false
			end
		end
	end


	---Applying---
	if humanoid.WalkSpeed ~= finalWalkSpeed then
		humanoid.WalkSpeed = finalWalkSpeed
	end

	if humanoid.JumpPower ~= finalJumpPower then
		humanoid.JumpPower = finalJumpPower
	end

	if finalJumpPower == 0 or stateService.checkState(character,"NoJump")  then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	else
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end

return StateHandler
