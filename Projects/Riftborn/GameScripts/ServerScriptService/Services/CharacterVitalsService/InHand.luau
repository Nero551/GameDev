local InHand = {}

function InHand:PutInHand(character:Model, argumentData)
	local CharacterVitalsService = require(script.Parent)
    local toolId = argumentData.ToolId

    if CharacterVitalsService.CharacterVitals[character].InHand ~= toolId then
        CharacterVitalsService.CharacterVitals[character].InHand = toolId
    end
end

function InHand:RemoveFromHand(character: Model, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local toolId = argumentData.ToolId

	if CharacterVitalsService.CharacterVitals[character].InHand == toolId then
		CharacterVitalsService.CharacterVitals[character].InHand = ""
	end
end

return InHand