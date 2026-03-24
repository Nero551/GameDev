local Movement = {}

function Movement:ModifyFlashStep(character:Model, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	local flashStepData = VitalsService.CharacterVitals[character].FlashStep
	local FlashStepChange = argumentData.FlashStepChange
		
	flashStepData.CurrentFlashStep = math.min(flashStepData.CurrentFlashStep + FlashStepChange, flashStepData.MaxFlashStep)	
end

function Movement:ModifyWalkSpeed(character:Model, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	local vitals = VitalsService.CharacterVitals[character]
	local change = argumentData.WalkSpeed

	vitals.WalkSpeed = change
	Movement:Apply(character)
end

function Movement:ModifyJumpPower(character:Model, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	local vitals = VitalsService.CharacterVitals[character]
	local change = argumentData.JumpPower
	
	vitals.JumpPower = change
	Movement:Apply(character)
end

function Movement:Apply(character:Model)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	local vitals = VitalsService.CharacterVitals[character]
	local humanoid = character:WaitForChild("Humanoid")
	
	humanoid.WalkSpeed = vitals.WalkSpeed
	humanoid.JumpPower = vitals.JumpPower
end

return Movement
