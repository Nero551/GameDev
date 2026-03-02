--DefualtHit

local replicatedStorage = game:GetService("ReplicatedStorage")

local assets = replicatedStorage:WaitForChild("Assets")
local StateChecker = require(replicatedStorage.Modules.StateChecker)

return function(arguementData:any)
	local target:Model = arguementData.Target
	local ailment = arguementData.Ailment
	local state = arguementData.State

	if target then
		local rootPart = target:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local clone = rootPart:FindFirstChild(ailment)
			if not clone then
				clone =  assets.Shared.Effects.AilmentEffects[ailment]:Clone()
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
			end
			while StateChecker:CheckState(target, state) do
				task.wait(0.1)
			end

			if not StateChecker:CheckState(target, state) then
				clone:Destroy()
			end
		end
	end
end