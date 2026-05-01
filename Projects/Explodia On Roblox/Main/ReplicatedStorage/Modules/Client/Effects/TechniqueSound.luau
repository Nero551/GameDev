return function(arguementData: any)
	local sound = arguementData.Sound
	local hitboxName = arguementData.HitBoxName
	local Volume: number? = arguementData.Volume

	local parent = workspace.World.Hitboxes:FindFirstChild(hitboxName)

	if sound and parent then
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
		warn("SoundName:", sound or "nil", "Parent:", parent and parent:GetFullName() or "nil", "isn't specified")
	end
end
