local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local abilityData = {
	storedData = {},
}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		abilityData.storedData[module.Name] = ModuleLoader:Load("Shared", module.Name)
	end
end



function abilityData:GetAbilityData(weapon, abilityLetter)
	
	if abilityData.storedData[weapon] then
		if not abilityLetter then
			return abilityData.storedData[weapon]
		end
		
		if abilityData.storedData[weapon][abilityLetter] then
			return abilityData.storedData[weapon][abilityLetter]
		end
	end
	return
end





return abilityData
