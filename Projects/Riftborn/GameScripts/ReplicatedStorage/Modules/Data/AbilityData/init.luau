local abilityData = {
	storedData = {},
}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		abilityData.storedData[module.Name] = require(module)
	end
end



function abilityData.getAbilityData(weapon, abilityLetter)
	
	if abilityData.storedData[weapon] then
		if abilityData.storedData[weapon][abilityLetter] then
			return abilityData.storedData[weapon][abilityLetter]
		end
	end
	return
end





return abilityData