local ActiveHand = {}

function ActiveHand:SetActiveHand(character:Model, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
    local itemID = argumentData.ItemID

    if VitalsService.CharacterVitals[character].ActiveHand == itemID then
		VitalsService.CharacterVitals[character].ActiveHand = ""
	else
		VitalsService.CharacterVitals[character].ActiveHand = itemID
    end
end

return ActiveHand
