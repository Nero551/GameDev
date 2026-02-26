local StatusAilments = {}

function StatusAilments:AddAilment(character , argumentData)
	local ailmentTime = argumentData.AilmentTime
	local ailmentName = argumentData.AilmentName
	local ailmentDuration = argumentData.AilmentDuration
	
	
	local CharacterVitalsService = require(script.Parent)
	local characterAilments = CharacterVitalsService.CharacterVitals[character].StatusAilments
	
	characterAilments[ailmentName] = {}
	characterAilments[ailmentName] = {
		["LastProc"] = ailmentTime,
		["Duration"] = ailmentDuration,
	}
	
end

function StatusAilments:RemoveAilment(character , argumentData)
	local ailmentName = argumentData.AilmentName
	local CharacterVitalsService = require(script.Parent)
	local characterAilments = CharacterVitalsService.CharacterVitals[character].StatusAilments
	
	if characterAilments[ailmentName] then
		characterAilments[ailmentName] = nil
	end
end

return StatusAilments
