--DefualtHit

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

local assets = replicatedStorage:WaitForChild("Assets")
local effects = assets.Effects

local cachedSounds = {}
for _,sound in assets.Sounds:GetDescendants() do
	if  sound:IsA("Sound") then
		local fullName = sound:GetFullName()
		fullName = fullName:split("ReplicatedStorage.Assets.Sounds.")[2]
		cachedSounds[fullName] = sound
	end
end


return function(arguementData:any)
	local  soundName:string = arguementData.SoundName
	local parent:BasePart? = arguementData.Parent
	
	
	if soundName and parent then
		local foundSound:Sound? = cachedSounds[soundName]
		if foundSound then
			local clone:Sound? = foundSound:Clone()
			clone.Parent = parent
			if not clone then
			end
			clone:Play()
			task.delay(foundSound.TimeLength, function()
				clone:Destroy()
			end)
		end	
	end

end