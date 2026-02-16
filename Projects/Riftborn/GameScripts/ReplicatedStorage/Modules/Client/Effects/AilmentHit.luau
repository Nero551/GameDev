--DefualtHit

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

local assets = replicatedStorage:WaitForChild("Assets")

return function(arguementData:any)
	local target:Model = arguementData.Target
	local ailment = arguementData.Ailment
	local Duration = arguementData.Duration
	
	if target then
		local rootPart = target:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local clone = rootPart:FindFirstChild(ailment)
			if not clone then
				local clone =  assets.Shared.Effects.AilmentEffects[ailment]:Clone()
				clone.Parent = rootPart
				for _,v in clone:GetDescendants() do
					if v:IsA("ParticleEmitter") then
						v.Enabled = true
					end
				end
			end

			debris:AddItem(clone, Duration)
		end
	end
end