local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = ReplicatedStorage:WaitForChild("Assets")

local cachedSounds = {}

for _, sound in assets:GetDescendants() do
	if sound:IsA("Sound") then
		local fullName = sound:GetFullName()
		fullName = fullName:split("ReplicatedStorage.Assets.")[2]
		cachedSounds[fullName] = sound
	end
end

return function(arguementData: any)
	local sound = arguementData.Sound
	local parent: BasePart? = arguementData.Parent
	local Volume: number? = arguementData.Volume

	if sound then
		local clone: Sound = sound:Clone()

		if parent then
			clone.Parent = parent
		end

		if Volume then
			clone.Volume = Volume
		end
		clone:Play()
		clone.Ended:Once(function()
			clone:Destroy()
		end)
	else
		warn("Sound Doesn't Exist", "isn't specified")
	end
end
