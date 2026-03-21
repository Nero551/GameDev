local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local ItemDatabase = {}

ItemDatabase.Sources = {
	Weapons = ModuleLoader:Load("Shared", "WeaponData").Weapons,
	Materials = ModuleLoader:Load("Shared", "MaterialData").Materials,
	Armors = ModuleLoader:Load("Shared", "ArmorData").Armors,
	Resources = ModuleLoader:Load("Shared", "ResourceData").Resources
}

function ItemDatabase:GetItemData(item)
	if not item then return nil end

	---If Id---
	for _, category in pairs(self.Sources) do
		local data = category[item]
		if data then
			return data, item
		end
	end

	---If Name---
	for _, category in pairs(self.Sources) do
		for id, itemData in pairs(category) do
			if itemData.Name == item then
				return itemData, id
			end
		end
	end
	return
end

return ItemDatabase
