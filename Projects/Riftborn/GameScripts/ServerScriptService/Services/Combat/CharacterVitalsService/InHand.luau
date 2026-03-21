local InHand = {}

function InHand:PutInHand(character:Model, argumentData)
	local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)
    local toolId = argumentData.ToolId

    if CharacterVitalsService.CharacterVitals[character].InHand ~= toolId then
        CharacterVitalsService.CharacterVitals[character].InHand = toolId
    end
end

function InHand:RemoveFromHand(character: Model, argumentData)
	local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)
	local toolId = argumentData.ToolId

	if CharacterVitalsService.CharacterVitals[character].InHand == toolId then
		CharacterVitalsService.CharacterVitals[character].InHand = ""
	end
end

return InHand
