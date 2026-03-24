--DefualtHit

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("Assets")
local StatusAilmentsData = require(ReplicatedStorage.Modules.Data.StatusAilmentsData)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)

return function(arguementData:any)
	local target:Model = arguementData.Target
	local ailment = arguementData.Ailment
	local state = StatusAilmentsData.Ailments[ailment].State
	local weaponUsed = arguementData.Weapon

	if target and weaponUsed then
		local rootPart = target:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local clone2 = assets.Weapons[weaponUsed.Name].Effects.HitEffect:Clone()
			clone2.Parent = rootPart
			for _, v in clone2:GetDescendants() do
				if v:IsA("ParticleEmitter") then
					if v:GetAttribute("EmitDelay") and v:GetAttribute("EmitDelay") > 0 then
						task.delay(v:GetAttribute("EmitDelay"), function()
							v:Emit(v:GetAttribute("EmitCount"))
						end)
					else
						v:Emit(v:GetAttribute("EmitCount"))
					end
				end
			end
			Debris:AddItem(clone2, 1.5)

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
