local Health = {}

function Health:ModifyHealth(character:Model?, argumentData)
	local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)
	local healthData = CharacterVitalsService:GetVital(character, "Health")
	local healthChange = argumentData.HealthChange
	
	healthData.CurrentHealth = math.clamp(healthData.CurrentHealth + healthChange, 0 , healthData.MaxHealth)
	Health:Apply(character)
end

function Health:ModifyMaxHealth(character:Model?, argumentData)
	local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)
	local healthData = CharacterVitalsService:GetVital(character, "Health")
	
	local maxHealth = argumentData.MaxHealth
	
	
	healthData.MaxHealth = maxHealth
	if healthData.CurrentHealth > healthData.MaxHealth then
		healthData.CurrentHealth = healthData.MaxHealth
	end
	
	healthData.HealthRegen = maxHealth/100
	
	Health:Apply(character)
end


function Health:Apply(character)
	local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)
	local healthData = CharacterVitalsService:GetVital(character, "Health")
	local humanoid:Humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	if healthData.CurrentHealth == 0  then
		healthData.HealthRegen = 0
	end
	
	humanoid.Health = healthData.CurrentHealth
	humanoid.MaxHealth = healthData.MaxHealth
	
end

return Health
