local Movement = {}

function Movement:ModifyFlashStep(character:Model?, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local flashStepData = CharacterVitalsService.CharacterVitals[character].FlashStep
	local FlashStepChange = argumentData.FlashStepChange
		
	flashStepData.CurrentFlashStep = math.min(flashStepData.CurrentFlashStep + FlashStepChange, flashStepData.MaxFlashStep)	
end

return Movement
