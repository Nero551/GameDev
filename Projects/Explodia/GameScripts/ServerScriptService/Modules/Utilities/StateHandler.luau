local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ServerScriptService.Services.Core.DataService)
local StateService = require(ServerScriptService.Services.Core.StateService)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

local StateHandler = {}

local statePriority = {
	-- Highest priority: prevents all movement
	{ Name = "Dead", WS = 0, JP = 0 },
	{ Name = "Stunned", WS = 0, JP = 0 },
	{ Name = "NoMove", WS = 0, JP = 0 },
	{ Name = "BlockBroken", WS = 0, JP = 0 },
	{ Name = "Dashing", WS = 0, JP = 0 },
	{ Name = "FlashStepEndLag", WS = 0, JP = 0 },

	---Status Effects--
	{ Name = "Frozen", WS = 0, JP = 0 },

	-- Combat-related movement limitations
	{ Name = "Casting", WS = 0, JP = 0 },
	{ Name = "Attacking", WS = 10, JP = 0 },
	{ Name = "Blocking", WS = 7, JP = 0 },
	{ Name = "NoSprint", WS = 10, JP = 0 },

	-- Special movement states
	{ Name = "FlashStep", WS = 64, JP = 50 },
	{ Name = "Sprinting", WS = 32, JP = 50 },
}

function StateHandler:HandleStates(character: Model, updateRate, runSpeed)
	local humanoid = character:WaitForChild("Humanoid")
	local stateFolder = character:WaitForChild("State")

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

	---Apply Agility---
	if
		Players:GetPlayerFromCharacter(character) and DataService.PlayerDatas[Players:GetPlayerFromCharacter(character)]
	then
		local agility = DataService:GetTable(Players:GetPlayerFromCharacter(character), "Stats")
		if agility then
			agility = agility.MainStats.Agility.Final
			finalWalkSpeed += (agility * 0.005) + (8 * (agility / (agility + 150)))
			finalJumpPower += (agility * 0.005) + (8 * (agility / (agility + 150)))
		end
	end
	---Applying---
	if VitalsService:GetVital(character, "WalkSpeed") ~= finalWalkSpeed then
		VitalsService:ModifyVital(character, "Movement", "ModifyWalkSpeed", {
			["WalkSpeed"] = finalWalkSpeed,
		})
	end

	if VitalsService:GetVital(character, "JumpPower") ~= finalJumpPower then
		VitalsService:ModifyVital(character, "Movement", "ModifyJumpPower", {
			["JumpPower"] = finalJumpPower,
		})
	end

	if finalJumpPower == 0 or StateChecker:CheckState(character, "NoJump") then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	else
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end

	---Updating Durations---
	for stateName, info in StateService.State[character] do
		if info.Duration then
			local stateValue = stateFolder:FindFirstChild(stateName)
			info.Duration -= updateRate
			for attrName, Value in pairs(info) do
				stateValue:SetAttribute(attrName, Value)
			end

			if info.Duration <= 0 then
				StateService:RemoveState(character, stateName)
			end
		end
	end
end

return StateHandler
