local Stamina = {}

function Stamina:ModifyStamina(character: Model?, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	local staminaData = VitalsService:GetVital(character, "Stamina")
	local StaminaChange = argumentData.StaminaChange

	staminaData.CurrentStamina = math.min(staminaData.CurrentStamina + StaminaChange, staminaData.MaxStamina)
end

function Stamina:ModifyMaxStamina(character: Model?, argumentData)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
	local staminaData = VitalsService:GetVital(character, "Mana")
	local maxStamina = argumentData.MaxStamina

	staminaData.MaxStamina = maxStamina

	if staminaData.CurrentStamina < 0 then
		staminaData.CurrentStamina = 0
	end
	if staminaData.CurrentStamina > staminaData.MaxStamina then
		staminaData.CurrentStamina = staminaData.MaxStamina
	end

	staminaData.StaminaRegen = maxStamina / 100
end

return Stamina
