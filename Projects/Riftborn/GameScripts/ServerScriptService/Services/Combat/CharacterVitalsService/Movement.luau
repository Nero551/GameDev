local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local Movement = {}

function Movement:ModifyFlashStep(character:Model, argumentData)
	local CharacterVitalsService = ModuleLoader:Load("Server", "CharacterVitalsService")
	local flashStepData = CharacterVitalsService.CharacterVitals[character].FlashStep
	local FlashStepChange = argumentData.FlashStepChange
		
	flashStepData.CurrentFlashStep = math.min(flashStepData.CurrentFlashStep + FlashStepChange, flashStepData.MaxFlashStep)	
end

function Movement:ModifyWalkSpeed(character:Model, argumentData)
	local CharacterVitalsService = ModuleLoader:Load("Server", "CharacterVitalsService")
	local characterVitals = CharacterVitalsService.CharacterVitals[character]
	local change = argumentData.WalkSpeed

	characterVitals.WalkSpeed = change
	Movement:Apply(character)
end

function Movement:ModifyJumpPower(character:Model, argumentData)
	local CharacterVitalsService = ModuleLoader:Load("Server", "CharacterVitalsService")
	local characterVitals = CharacterVitalsService.CharacterVitals[character]
	local change = argumentData.JumpPower
	
	characterVitals.JumpPower = change
	Movement:Apply(character)
end

function Movement:Apply(character:Model)
	local CharacterVitalsService = ModuleLoader:Load("Server", "CharacterVitalsService")
	local characterVitals = CharacterVitalsService.CharacterVitals[character]
	local humanoid = character:WaitForChild("Humanoid")
	
	humanoid.WalkSpeed = characterVitals.WalkSpeed
	humanoid.JumpPower = characterVitals.JumpPower
end

return Movement
