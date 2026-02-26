local Health = {}

function Health:ModifyHealth(character:Model?, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local healthData = CharacterVitalsService:GetVital(character, "Health")
	local healthChange = argumentData.HealthChange
	
	healthData.CurrentHealth = math.clamp(healthData.CurrentHealth + healthChange, 0 , healthData.MaxHealth)
	
	Health:Apply(character)
end

function Health:ModifyMaxHealth(character:Model?, argumentData)
	local CharacterVitalsService = require(script.Parent)
	local healthData = CharacterVitalsService:GetVital(character, "Health")
	
	local maxHealth = argumentData.MaxHealth
	
	
	local humanoid:Humanoid = character:WaitForChild("Humanoid")
	healthData.MaxHealth = maxHealth
	if healthData.CurrentHealth > healthData.MaxHealth then
		healthData.CurrentHealth = healthData.MaxHealth
	end
	
	healthData.HealthRegen = maxHealth/100
	
	Health:Apply(character)
end


function Health:Apply(character)
	local CharacterVitalsService = require(script.Parent)
	local healthData = CharacterVitalsService:GetVital(character, "Health")
	local humanoid:Humanoid = character:WaitForChild("Humanoid")
	
	if healthData.CurrentHealth == 0  then
		healthData.HealthRegen = 0
	end
	
	humanoid.Health = healthData.CurrentHealth
	humanoid.MaxHealth = healthData.MaxHealth
	
end

return Health
