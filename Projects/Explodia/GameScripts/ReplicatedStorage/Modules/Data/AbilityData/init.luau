local abilityData = {
	storedData = {},
}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		abilityData.storedData[module.Name] = require(module)
	end
end

function abilityData:GetAbilityData(abilityName)
	if abilityData.storedData[abilityName] then
		return abilityData.storedData[abilityName]
	end
	return
end

return abilityData
