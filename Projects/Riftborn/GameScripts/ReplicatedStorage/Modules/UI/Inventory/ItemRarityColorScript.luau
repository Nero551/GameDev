
return function(itemRarityText)
	local RarityData = require(game.ReplicatedStorage.Modules.Data.RarityData)
	local itemName = itemRarityText.Parent.ItemName
	
	itemRarityText.Changed:Connect(function()
		local rarity = RarityData[itemRarityText.Text]
		if rarity then
			local rarityColor = rarity.Color
			itemRarityText.TextColor3 = Color3.fromHex(rarityColor)
			itemName.TextColor3 = Color3.fromHex(rarityColor)
		end

	end)
end