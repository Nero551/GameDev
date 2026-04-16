--DefualtHit

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("Assets")

return function(arguementData: any)
	local target: Model = arguementData.Target
	local weaponUsed = arguementData.Weapon
	local technique = arguementData.Technique

	if target then
		local rootPart = target:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local clone
			if weaponUsed then
				clone = assets.Weapons[weaponUsed].Effects.HitEffect:Clone()
			elseif technique then
				clone = assets.Techniques[technique].HitEffect:Clone()
			end
			clone.Parent = rootPart
			for _, v in clone:GetDescendants() do
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
			Debris:AddItem(clone, 1.5)
		end
	end
end
