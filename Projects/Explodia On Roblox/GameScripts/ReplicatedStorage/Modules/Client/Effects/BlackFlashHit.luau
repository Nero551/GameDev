--DefualtHit

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("Assets")

return function(arguementData: any)
	local target: Model = arguementData.Target

	if target then
		local rootPart = target:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local clone = assets.Combat.BlackFlash.VFX:Clone()
			clone.Parent = rootPart
			local weld = Instance.new("Weld")
			weld.Part0 = clone
			weld.Part1 = rootPart
			weld.Parent = clone

			for _, v in clone:GetDescendants() do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				end
			end
			Debris:AddItem(clone, 1.5)
		end
	end
end
