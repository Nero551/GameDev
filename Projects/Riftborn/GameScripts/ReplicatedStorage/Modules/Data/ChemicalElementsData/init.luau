local ChemicalElementsData = {}

local ChemicalElements = {}

for _,module in script:GetChildren() do
    if module:IsA("ModuleScript") then
        ChemicalElements[module.Name] = require(module)
    end
end

function ChemicalElementsData:GetElement(elementName)
    if ChemicalElements[elementName] then
        return ChemicalElements[elementName]
    end
    warn("Element Doesn't Exist")
    return nil
end

return ChemicalElementsData