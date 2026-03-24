local Mana = {}



function Mana:ModifyMana(character:Model?, argumentData)
	local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)
	local manaData = CharacterVitalsService:GetVital(character, "Mana")
	local ManaChange = argumentData.ManaChange
	
	manaData.CurrentMana = math.min(manaData.CurrentMana + ManaChange,	manaData.MaxMana)
end

function Mana:ModifyMaxMana(character:Model?, argumentData)
	local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)
	local manaData = CharacterVitalsService:GetVital(character, "Mana")
	local maxMana = argumentData.MaxMana
	
	manaData.MaxMana = maxMana
	
	if manaData.CurrentMana < 0  then
		manaData.CurrentMana = 0
	end
	if manaData.CurrentMana > manaData.MaxMana then
		manaData.CurrentMana =  manaData.MaxMana
	end
	
	manaData.ManaRegen = maxMana / 100
	
end

return Mana
