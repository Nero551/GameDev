--DefualtHit

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

local assets = replicatedStorage:WaitForChild("Assets")

return function(arguementData:any)
	local VFX:Attachment? = arguementData.VFX
	local hitboxName = arguementData.HitBoxName
	local hitbox = workspace.World.Hitboxes:FindFirstChild(hitboxName)
	
	if VFX then
		local clone =  VFX:Clone()
		clone.Parent = workspace.World.Effects
		clone.CFrame = hitbox.CFrame
		for _,particle:ParticleEmitter? in clone:GetDescendants() do
			if particle:IsA("ParticleEmitter") then
				if particle:GetAttribute("EmitDelay") and particle:GetAttribute("EmitDelay") > 0 then
					task.delay(particle:GetAttribute("EmitDelay"), function()
						particle:Emit(particle:GetAttribute("EmitCount"))
					end)
				else
					particle:Emit(particle:GetAttribute("EmitCount"))
				end
			end
		end
		debris:AddItem(clone, 20)
	end
end