--DefualtHit

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage:WaitForChild("Assets")



return function(arguementData:any)
	local target:Model = arguementData.Target
	local weaponUsed = arguementData.Weapon
	local blockCounter = arguementData.BlockCounter
	
	
	if target and weaponUsed then
		local rootPart = target:FindFirstChild("HumanoidRootPart")
		if rootPart then
			local clone =  assets.Shared.Combat.Block.BlockEffects["Block"..tostring(blockCounter)]:Clone()
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
	end
end