local InHand = {}

function InHand:PutInHand(character:Model, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
    local toolId = argumentData.ToolId

    if VitalsService.CharacterVitals[character].InHand ~= toolId then
        VitalsService.CharacterVitals[character].InHand = toolId
    end
end

function InHand:RemoveFromHand(character: Model, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	local toolId = argumentData.ToolId

	if VitalsService.CharacterVitals[character].InHand == toolId then
		VitalsService.CharacterVitals[character].InHand = ""
	end
end

return InHand
