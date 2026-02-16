
local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage:WaitForChild("Assets")

local cachedSounds = {}

for _,sound in assets:GetDescendants() do
	if  sound:IsA("Sound") then
		local fullName = sound:GetFullName()
		fullName = fullName:split("ReplicatedStorage.Assets.")[2]
		cachedSounds[fullName] = sound
	end
end

return function(arguementData:any)
	local  soundName:string = arguementData.SoundName
	local parent:BasePart? = arguementData.Parent
	local Volume:number? = arguementData.Volume
	
	
	if soundName and parent then
		local foundSound:Sound? = cachedSounds[soundName]
		if foundSound then
			local clone:Sound? = foundSound:Clone()
			clone.Parent = parent
			
			if Volume then
				clone.Volume = Volume
			end
			clone:Play()
			task.delay(foundSound.TimeLength, function()
				clone:Destroy()
			end)
		end	
	end

end