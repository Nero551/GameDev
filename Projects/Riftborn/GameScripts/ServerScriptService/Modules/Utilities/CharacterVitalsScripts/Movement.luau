local Movement = {}

function Movement:ModifyFlashStep(character:Model?, argumentData)
	local CharacterVitalsService = require(script.Parent.Parent.Parent.Parent.Services.CharacterVitalsService)
	local flashStepData = CharacterVitalsService.CharacterVitals[character].FlashStep
	local FlashStepChange = argumentData.FlashStepChange
		
	flashStepData.CurrentFlashStep = math.min(flashStepData.CurrentFlashStep + FlashStepChange, flashStepData.MaxFlashStep)	
end

return Movement
