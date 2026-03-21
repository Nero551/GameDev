local abilityData = {
	storedData = {},
}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		abilityData.storedData[module.Name] = require(module)
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
