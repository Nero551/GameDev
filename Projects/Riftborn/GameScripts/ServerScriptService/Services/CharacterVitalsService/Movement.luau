local Movement = {}

function Movement:ModifyFlashStep(character:Model, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local flashStepData = CharacterVitalsService.CharacterVitals[character].FlashStep
	local FlashStepChange = argumentData.FlashStepChange
		
	flashStepData.CurrentFlashStep = math.min(flashStepData.CurrentFlashStep + FlashStepChange, flashStepData.MaxFlashStep)	
end

function Movement:ModifyAirJump(character:Model, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local airJumpData = CharacterVitalsService.CharacterVitals[character].AirJump
	local AirJumpChange = argumentData.AirJumpChange
		
	airJumpData.CurrentAirJump = math.min(airJumpData.CurrentAirJump + AirJumpChange, airJumpData.MaxAirJump)	
end


function Movement:ModifyWalkSpeed(character:Model, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local characterVitals = CharacterVitalsService.CharacterVitals[character]
	local change = argumentData.WalkSpeed

	characterVitals.WalkSpeed = change
	Movement:Apply(character)
end

function Movement:ModifyJumpPower(character:Model, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local characterVitals = CharacterVitalsService.CharacterVitals[character]
	local change = argumentData.JumpPower
	
	characterVitals.JumpPower = change
	Movement:Apply(character)
end

function Movement:Apply(character:Model)
	local CharacterVitalsService = require(script.Parent)
	local characterVitals = CharacterVitalsService.CharacterVitals[character]
	local humanoid = character:WaitForChild("Humanoid")
	
	humanoid.WalkSpeed = characterVitals.WalkSpeed
	humanoid.JumpPower = characterVitals.JumpPower
end

return Movement
