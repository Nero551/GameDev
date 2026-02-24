local Combat = {}

function Combat:ModifySwingNumber(character:Model?, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local swingNumberChange = argumentData.SwingNumberChange
	if swingNumberChange == 0 then
		CharacterVitalsService.CharacterVitals[character].SwingNumber = swingNumberChange
		
	else
		CharacterVitalsService.CharacterVitals[character].SwingNumber += swingNumberChange
	end
end


function Combat:ModifyLastCombo(character:Model?, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local lastComboChange = argumentData.LastComboChange
	
	CharacterVitalsService.CharacterVitals[character].LastCombo = lastComboChange
	
end

function Combat:ModifyLastSwing(character:Model?, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local lastSwingChange = argumentData.LastSwingChange

	CharacterVitalsService.CharacterVitals[character].LastSwing = lastSwingChange

end

function Combat:ModifyBlockCounter(character, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local vitals = CharacterVitalsService.CharacterVitals[character]
	if not vitals then return end

	local change = argumentData.BlockCounterChange

	if change == 0 then
		vitals.BlockCounter = 0
	else
		vitals.BlockCounter = math.min(vitals.BlockCounter + change, 4)
	end
end


return Combat
