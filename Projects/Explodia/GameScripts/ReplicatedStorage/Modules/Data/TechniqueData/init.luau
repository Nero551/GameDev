local TechniqueData = {
	storedData = {},
}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		TechniqueData.storedData[module.Name] = require(module)
	end
end

function TechniqueData:GetTechniqueData(techniqueID)
	for moduleName,module in TechniqueData.storedData do
		if module[techniqueID] then
			return module[techniqueID]
		end
	end
	return
end

return TechniqueData
