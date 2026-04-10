local TechniqueData = {
	storedData = {},
}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		TechniqueData.storedData[module.Name] = require(module)
	end
end

function TechniqueData:GetTechniqueData(techniqueID)
	for moduleName, module in TechniqueData.storedData do
		if module[techniqueID] then
			return module[techniqueID]
		end
	end
	return
end

function TechniqueData:GetTechniqueID(techniqueName)
	if not techniqueName then
		return nil
	end
	print(techniqueName)
	for moduleName, module in TechniqueData.storedData do
		for id, data in pairs(module) do
			if data.TechniqueName == techniqueName then
				return id
			end
		end
	end

	return nil
end

return TechniqueData
