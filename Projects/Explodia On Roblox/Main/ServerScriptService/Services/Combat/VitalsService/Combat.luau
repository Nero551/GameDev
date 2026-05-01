local Combat = {}

function Combat:ModifySwingNumber(character:Model?, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	local swingNumberChange = argumentData.SwingNumberChange
	if swingNumberChange == 0 then
		VitalsService.CharacterVitals[character].SwingNumber = swingNumberChange
		
	else
		VitalsService.CharacterVitals[character].SwingNumber += swingNumberChange
	end
end


function Combat:ModifyLastCombo(character:Model?, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	local lastComboChange = argumentData.LastComboChange
	
	VitalsService.CharacterVitals[character].LastCombo = lastComboChange
	
end

function Combat:ModifyLastSwing(character:Model?, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	local lastSwingChange = argumentData.LastSwingChange

	VitalsService.CharacterVitals[character].LastSwing = lastSwingChange

end

function Combat:ModifyBlockCounter(character, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	local vitals = VitalsService.CharacterVitals[character]
	if not vitals then return end

	local change = argumentData.BlockCounterChange

	if change == 0 then
		vitals.BlockCounter = 0
	else
		vitals.BlockCounter = math.min(vitals.BlockCounter + change, 4)
	end
end


return Combat
