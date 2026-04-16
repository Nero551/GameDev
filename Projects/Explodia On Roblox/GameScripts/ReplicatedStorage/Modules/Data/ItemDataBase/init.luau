local ItemDatabase = {}

ItemDatabase.Sources = {
	Weapons = require(game.ReplicatedStorage.Modules.Data.ItemDataBase.WeaponData).Weapons,
	Materials = require(game.ReplicatedStorage.Modules.Data.ItemDataBase.MaterialData).Materials,
	Armors = require(game.ReplicatedStorage.Modules.Data.ItemDataBase.ArmorData).Armors,
	Resources = require(game.ReplicatedStorage.Modules.Data.ItemDataBase.ResourceData).Resources
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
