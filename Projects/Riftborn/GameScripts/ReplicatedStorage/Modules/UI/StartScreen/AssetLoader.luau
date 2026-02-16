return function()
	local ContentProvider = game:GetService("ContentProvider")

	local assetsToLoad = {}

	local function getAllAssets(parent)
		for _, asset in parent:GetDescendants() do
			table.insert(assetsToLoad, asset)
		end
	end

	getAllAssets(game.ReplicatedStorage)
	getAllAssets(game.Workspace)

	ContentProvider:PreloadAsync(assetsToLoad)
	warn(#assetsToLoad .. " assets preloaded!")

end