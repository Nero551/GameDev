local runService = game:GetService("RunService")
local CharacterVitalsService = require(script.Parent.Parent.Services.CharacterVitalsService)
local StateService = require(game.ReplicatedStorage.Modules.StateService)

local RegenService = {}
function RegenService:ManaRegen()
	runService.Heartbeat:Connect(function(dt)
		for character, data in pairs(CharacterVitalsService.CharacterVitals) do
			if data.Mana.CurrentMana < data.Mana.MaxMana then

				local dm = dt*data.Mana.ManaRegen

				CharacterVitalsService:ModifyVital(character, "Mana", "ModifyMana", {
					["ManaChange"] = dm
				})
			end
		end
	end)
end

function RegenService:HealthRegen()
	runService.Heartbeat:Connect(function(dt)
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
	end)
end


function RegenService:FlashStepRegen()
	local cooldown = 15
	local elapsed = 0
	runService.Heartbeat:Connect(function(dt)
		for character, data in pairs(CharacterVitalsService.CharacterVitals) do
			if data.FlashStep.CurrentFlashStep < data.FlashStep.MaxFlashStep then
				elapsed = elapsed + dt
				if elapsed >= cooldown then
					CharacterVitalsService:ModifyVital(character, "Movement", "ModifyFlashStep", {
						["FlashStepChange"] = 1
					})
					elapsed = 0
				end
			end
		end
	end)
end

function RegenService:BlockCounterRegen()
	local cooldown = 5
	local elapsed = 0
	runService.Heartbeat:Connect(function(dt)
		for character, data in pairs(CharacterVitalsService.CharacterVitals) do
			if not StateService.checkState(character, "Blocking") then
				elapsed = elapsed + dt
				
			else
				elapsed = 0
			end
			
			if elapsed >= 5 then
				CharacterVitalsService:ModifyVital(character , "Combat", "ModifyBlockCounter", {
					["BlockCounterChange"] = 0
				})
				elapsed = 0
			end
		end
	end)
end

return RegenService
