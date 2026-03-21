local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local StateChecker = ModuleLoader:Load("Shared", "StateChecker")
local CharacterVitalsService = ModuleLoader:Load("Server", "CharacterVitalsService")

local StateHandler = {}


local statePriority = {
	-- Highest priority: prevents all movement
	{Name = "Dead", WS = 0, JP = 0},
	{Name = "Stunned", WS = 0, JP = 0},
	{Name = "NoMove", WS = 0, JP = 0},
	{Name = "BlockBroken", WS = 0, JP = 0},
	{Name = "Dashing", WS = 0, JP = 0},
	{Name = "FlashStepEndLag", WS = 0, JP = 0},
	
	---Status Ailments--
	{Name = "Frozen", WS = 0, JP = 0},
	
	-- Combat-related movement limitations
	{Name = "Casting", WS = 0, JP = 0},
	{Name = "Attacking", WS = 10, JP = 0},
	{Name = "Blocking", WS = 7, JP = 0},
	{Name = "NoSprint", WS = 10, JP = 0},   

	-- Special movement states
	{Name = "FlashStep", WS = 64, JP = 50},   
	{Name = "Sprinting", WS = 32, JP = 50}, 

}


function StateHandler:HandleStates(character:Model ,dt, runSpeed)
	local humanoid = character:WaitForChild("Humanoid")
	
	------StateHandler------
	local finalWalkSpeed = 5
	local finalJumpPower = 50 


	for _, stateInfo in ipairs(statePriority) do
		if StateChecker:CheckState(character, stateInfo.Name) then
			
			if stateInfo.Name == "Sprinting" then
				finalWalkSpeed = runSpeed or stateInfo.WS
				finalJumpPower = stateInfo.JP
			else
				finalWalkSpeed = stateInfo.WS
				finalJumpPower = stateInfo.JP
			end
			break 
		end
	end
	
	---Applying---
	if CharacterVitalsService:GetVital(character , "WalkSpeed") ~= finalWalkSpeed then
		
		CharacterVitalsService:ModifyVital(character, "Movement", "ModifyWalkSpeed", {
			["WalkSpeed"] = finalWalkSpeed
			
		})		
	end

	if CharacterVitalsService:GetVital(character , "JumpPower") ~= finalJumpPower then
		CharacterVitalsService:ModifyVital(character, "Movement", "ModifyJumpPower", {
			["JumpPower"] = finalJumpPower

		})	
	end
	
	if finalJumpPower == 0 or StateChecker:CheckState(character,"NoJump")  then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	else
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end

return StateHandler
