return function()
	local ContentProvider = game:GetService("ContentProvider")

	local assetsToLoad = {}

	local function getAllAssets(parent:Folder?)
		for _, asset in parent:GetDescendants() do
			if asset:IsA("MeshPart") or asset:IsA("UnionOperation") or asset:IsA("Model") then
				table.insert(assetsToLoad, asset)
			end
		end
	end

	getAllAssets(game.ReplicatedStorage)
	getAllAssets(game.Workspace)

	ContentProvider:PreloadAsync(assetsToLoad)
	warn(#assetsToLoad .. " assets preloaded!")

end