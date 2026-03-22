--DefualtHit

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("Assets")
local effects = assets.Shared.Effects

return function(arguementData:any)
	local target = arguementData.Target
	local weaponUsed = arguementData.Weapon
	
	if target and weaponUsed then
		task.spawn(function()
			local rootPart = target:FindFirstChild("HumanoidRootPart")
			if rootPart then
				local clone =  effects.CoreEffects.BlockBreak:Clone()
				clone.Parent = rootPart
				for _,v in clone:GetDescendants() do
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
		end)
		
		
		local clone  = effects.DizzyEffect:Clone()
		clone.Parent = target
		local weld = Instance.new("Weld")
		weld.Part0 = target.Head
		weld.Part1 = clone
		weld.Parent = clone
		
		clone.Parent = target
		
		task.delay(1.5 , function()
			for _, eff in clone:GetDescendants() do
				 if eff:IsA("ParticleEmitter")  then
						eff.Enabled = false
						
				 end
			end
			clone:Destroy()
		end)
		
		
		
	end


end