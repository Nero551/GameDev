local module = {}

module.connections = {}

module.loadedAnimations = {}

function module.loadAnims( animator:Animator , folder :Folder)
	for _,anim in folder:GetDescendants() do
		if anim:IsA("Animation") then
			local fullName = anim:GetFullName()
			fullName = fullName:split("ReplicatedStorage.Assets.Animations.")[2]
			
			module.loadedAnimations[fullName] = animator:LoadAnimation(anim)
		end
	end
end


return module
