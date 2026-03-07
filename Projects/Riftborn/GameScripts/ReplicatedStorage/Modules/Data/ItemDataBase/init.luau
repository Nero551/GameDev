local ItemDatabase = {}

ItemDatabase.Sources = {
	Weapons   = require(script.WeaponData).Weapons,
	Materials = require(script.MaterialData).Materials,
	Armors    = require(script.ArmorData).Armors,
	Resources = require(script.ResourceData).Resources
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
