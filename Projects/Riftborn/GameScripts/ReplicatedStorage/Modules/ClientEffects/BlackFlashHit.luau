--DefualtHit

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

local assets = replicatedStorage:WaitForChild("Assets")

return function(arguementData:any)
	local target:Model = arguementData.Target
	
	if target  then
		local rootPart = target:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local clone =  assets.Shared.Effects.BlackFlashEffect:Clone()
			clone.Parent = rootPart
			local weld = Instance.new("Weld")
			weld.Part0 = clone
			weld.Part1 = rootPart
			weld.Parent = clone
			
			
			for _,v in clone:GetDescendants() do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				end
			end
			debris:AddItem(clone, 1.5)
		end
	end
end