local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("Assets")
local StatusEffectsData = require(ReplicatedStorage.Modules.Data.StatusEffectsData)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)

return function(arguementData: any)
	local target: Model = arguementData.Target
	local statusEffectName = arguementData.StatusEffect
	local state = StatusEffectsData.StatusEffects[statusEffectName].State

	if target then
		local rootPart = target:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local clone = rootPart:FindFirstChild(statusEffectName)
			if not clone then
				clone = assets.Combat.StatusEffects.StatusEffectsVFX[statusEffectName]:Clone()
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
