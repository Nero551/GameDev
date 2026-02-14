local starterGui = game:GetService("StarterGui")
local stateService = require(script.Parent.StateService)

local StateHandler = {}

local statePriority = {
	-- Highest priority: prevents all movement
	{Name = "Dead", WS = 0, JP = 0},
	{Name = "Stunned", WS = 0, JP = 0},
	{Name = "NoMove", WS = 0, JP = 0},
	{Name = "BlockBroken", WS = 0, JP = 0},
	{Name = "Dashing", WS = 0, JP = 0},
	{Name = "FlashStepEndLag", WS = 0, JP = 0},

	-- Combat-related movement limitations
	{Name = "Casting", WS = 10, JP = 0},
	{Name = "Attacking", WS = 10, JP = 0},
	{Name = "Blocking", WS = 7, JP = 0},
	{Name = "NoSprint", WS = 10, JP = 0},   

	-- Special movement states
	{Name = "FlashStep", WS = 64, JP = 50},   
	{Name = "Sprinting", WS = 32, JP = 50}, 

}

function StateHandler:HandleStates(character:Model?)
	local humanoid = character:WaitForChild("Humanoid")
	
	------StateHandler------
	local finalWalkSpeed = 10 
	local finalJumpPower = 50 

	for _, stateInfo in ipairs(statePriority) do
		if stateService.checkState(character, stateInfo.Name) then
			finalWalkSpeed = stateInfo.WS
			finalJumpPower = stateInfo.JP
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
