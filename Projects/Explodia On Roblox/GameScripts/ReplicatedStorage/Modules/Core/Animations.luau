local function GetInstanceFromPath(pathString)
	local current = game

	for segment in string.gmatch(pathString, "[^%.]+") do
		current = current:FindFirstChild(segment)
		if not current then
			return nil
		end
	end

	return current
end

local Animations = {}

Animations.loadedAnimations = {}

function Animations:LoadAnimations(humanoid, folder: Folder)
	local animator = humanoid.Animator
	local character = humanoid.Parent

	Animations.loadedAnimations[character] = Animations.loadedAnimations[character] or {}

	for _, anim in folder:GetDescendants() do
		if anim:IsA("Animation") then
			local fullName = anim:GetFullName()
			fullName = fullName:split("ReplicatedStorage.Assets.")[2]
			Animations.loadedAnimations[character][fullName] = animator:LoadAnimation(anim)
		end
	end
end

function Animations:GetAnimation(humanoid, animation)
	local animator = humanoid.Animator
	local character = humanoid.Parent

	Animations.loadedAnimations[character] = Animations.loadedAnimations[character] or {}

	if not Animations.loadedAnimations[character][animation] then
		local animInstance = GetInstanceFromPath("ReplicatedStorage.Assets." .. animation)

		if animInstance then
			if animInstance:IsA("Animation") then
				Animations.loadedAnimations[character][animation] = animator:LoadAnimation(animInstance)
			end
		end
	end
	return Animations.loadedAnimations[character][animation]
end

return Animations
