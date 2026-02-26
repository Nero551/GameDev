return function()
	local ContentProvider = game:GetService("ContentProvider")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Workspace = game:GetService("Workspace")

	local assetsToLoad = {}

local validClasses = {
	-- Meshes & Parts
	"MeshPart",
	"UnionOperation",
	"CornerWedgePart",
	"TrussPart",
	"WedgePart",
	"Part",
	"Seat",
	"VehicleSeat",
	"BlockMesh",
	"SpecialMesh",

	-- Decals / Textures
	"Decal",
	"Texture",
	"Sky",

	-- Sounds / Audio
	"Sound",

	-- Animations
	"Animation",

	-- Tools / Gear
	"Tool",
	"HopperBin",

	-- Particle / Visual Effects
	"ParticleEmitter",
	"Trail",
	"Fire",
	"Smoke",
	"Sparkles",
	"Beam",

	-- Lights
	"PointLight",
	"SpotLight",
	"SurfaceLight",
	"BillboardGui",
	"SurfaceGui",

	-- GUI Elements
	"ImageLabel",
	"ImageButton",
	"Frame",
}
	local function getAllAssets(parent)
		for _, child in ipairs(parent:GetDescendants()) do
			for _,class in ipairs(validClasses) do
				if child:IsA(class) then
					table.insert(assetsToLoad, child)

				end
			end
		end
	end

	getAllAssets(ReplicatedStorage)
	getAllAssets(Workspace)
	getAllAssets(game.StarterGui)

	ContentProvider:PreloadAsync(assetsToLoad)
	print(#assetsToLoad .. " assets preloaded!")
end