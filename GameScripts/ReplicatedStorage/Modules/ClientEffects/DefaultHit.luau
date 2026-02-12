--DefualtHit

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

local assets = replicatedStorage:WaitForChild("Assets")
local effects = assets.Effects

return function(arguementData:any)
	local target:Model = arguementData.Target
	local weaponUsed :string = arguementData.weaponUsed
	
	if target and weaponUsed then
		local rootPart = target:FindFirstChild("HumanoidRootPart")
		if rootPart then
			if weaponUsed == "Fist" then
				local clone =  effects.CoreEffects.HitEffect:Clone()
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
				
				
			elseif weaponUsed == "Katana" or weaponUsed == "Dagger" or weaponUsed == "Cid Sword" then
				local clone =  effects.CoreEffects[weaponUsed.."SlashEffect"]:Clone()
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

		end
	end
end