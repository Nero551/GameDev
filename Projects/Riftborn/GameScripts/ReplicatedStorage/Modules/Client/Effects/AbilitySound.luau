
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assets = ReplicatedStorage:WaitForChild("Assets")

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
	local hitboxName = arguementData.HitBoxName
	local Volume:number? = arguementData.Volume
	
	local parent = workspace.World.Hitboxes:FindFirstChild(hitboxName)
	
	if soundName and parent then
		local foundSound:Sound? = cachedSounds[soundName]
		if foundSound then
			local clone:Sound? = foundSound:Clone()
			clone.Parent = parent
			
			if Volume then
				clone.Volume = Volume
			end
			clone:Play()
			clone.Ended:Once(function()
				clone:Destroy()
			end)
			
		else
			warn("Sound Not Found")
		end
		
	else
		warn(
			"SoundName:", soundName or "nil",
			"Parent:", parent and parent:GetFullName() or "nil",
			"isn't specified"
		)
	end

end