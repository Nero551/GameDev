--DefualtHit

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

local assets = replicatedStorage:WaitForChild("Assets")
local effects = assets.Shared.Effects

return function(arguementData:any)
	local target:Model = arguementData.Target
	local weaponUsed :string = arguementData.weaponUsed
	local  duration:number = arguementData.Duration
	
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
				debris:AddItem(clone, 1.5)
			end
		end)
		
		
		local clone  = effects.DizzyEffect:Clone()
		clone.Parent = target
		local weld = Instance.new("Weld")
		weld.Part0 = target.Head
		weld.Part1 = clone
		weld.Parent = clone
		
		clone.Parent = target
		
		task.delay(duration , function()
			for _, eff in clone:GetDescendants() do
				 if eff:IsA("ParticleEmitter")  then
						eff.Enabled = false
						
				 end
			end
			debris:AddItem(clone , 1.5)
		end)
		
		
		
	end


end