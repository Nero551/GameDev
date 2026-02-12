local abilityData = {
	storedData = {},
}


function abilityData.getAbilityData(abilityName:string)
	return abilityData.storedData[abilityName] or nil
end

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		abilityData.storedData[module.Name] = require(module)
	end
end



return abilityData