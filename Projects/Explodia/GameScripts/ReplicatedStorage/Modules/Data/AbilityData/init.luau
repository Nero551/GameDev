local abilityData = {
	storedData = {},
}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		abilityData.storedData[module.Name] = require(module)
	end
end

function abilityData:GetAbilityData(abilityID)
	for moduleName,module in abilityData.storedData do
		if module[abilityID] then
			return module[abilityID]
		end
	end
	return
end

return abilityData
