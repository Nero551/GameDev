local CharacterVitalsService = require(script.Parent.Parent.Services.CharacterVitalsService)
local StateService = require(game.ReplicatedStorage.Modules.StateService)


local RegenService = {}
local elapsedFlashStep = {}
local elapsedBlock = {}
function RegenService:ManaRegen(dt)
	for character, data in pairs(CharacterVitalsService.CharacterVitals) do
		if data.Mana.CurrentMana < data.Mana.MaxMana then

			local dm = dt*data.Mana.ManaRegen

			CharacterVitalsService:ModifyVital(character, "Mana", "ModifyMana", {
				["ManaChange"] = dm
			})
		end
	end
end

function RegenService:HealthRegen(dt)
	for character, data in pairs(CharacterVitalsService.CharacterVitals) do
		if data.Health.CurrentHealth < data.Health.MaxHealth then

			local dh
			if StateService.checkState(character,"In Combat") then
				dh = (dt*data.Health.HealthRegen) / 5
			else
				dh = dt*data.Health.HealthRegen
			end

			CharacterVitalsService:ModifyVital(character, "Health", "ModifyHealth", {
				["HealthChange"] = dh
			})
		end
	end
end


function RegenService:FlashStepRegen(dt)
	local cooldown = 15
	for character, data in pairs(CharacterVitalsService.CharacterVitals) do
		elapsedFlashStep[character] = (elapsedFlashStep[character] or 0) + dt
		if data.FlashStep.CurrentFlashStep < data.FlashStep.MaxFlashStep and elapsedFlashStep[character] >= cooldown then
			CharacterVitalsService:ModifyVital(character, "Movement", "ModifyFlashStep", { FlashStepChange = 1 })
			elapsedFlashStep[character] = 0
		end
	end
end
	
function RegenService:BlockCounterRegen(dt)
	local cooldown = 5
	for character, data in pairs(CharacterVitalsService.CharacterVitals) do
		
		if CharacterVitalsService:GetVital(character, "BlockCounter") > 0 then
			if not StateService.checkState(character,"Blocking") then
				elapsedBlock[character] = (elapsedBlock[character] or 0) + dt
			else
				elapsedBlock[character] = 0
			end

			if elapsedBlock[character] >= cooldown then
				CharacterVitalsService:ModifyVital(character , "Combat", "ModifyBlockCounter", { ["BlockCounterChange"] = 0 })
				elapsedBlock[character] = 0
			end
			
		else
			elapsedBlock[character] = 0
		end	
	end
end

return RegenService
