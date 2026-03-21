--DefualtHit

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StateChecker = require(ReplicatedStorage.Modules.Helpers.StateChecker)
local DynamicLight = require(ReplicatedStorage.Modules.Helpers.DynamicLight)

local assets = ReplicatedStorage:WaitForChild("Assets")

return function(arguementData:any)
	local VFX = arguementData.VFX
	local hitboxName = arguementData.HitBoxName
	local caster = arguementData.Caster
	local hitbox = workspace.World.Hitboxes:FindFirstChild(hitboxName)
	
	if VFX and hitbox then
		local clone:Part? =  VFX:Clone()
		clone.Parent = workspace.World.Effects
		clone.CFrame = hitbox.CFrame
		
		clone.Anchored = true
		clone.CanCollide = false
		clone.Massless = true
		clone.Transparency = 1
		
		for _,particle:ParticleEmitter? in clone:getDescendants() do
			if particle:IsA("SpotLight") or particle:IsA("PointLight") or particle:IsA("SurfaceLight") then
				DynamicLight:Destroy(particle, particle:GetAttribute("Duration"))
			end
			
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
		
		while StateChecker:CheckState(caster, "Casting") do
			task.wait(0.1)
		end
		
		if not StateChecker:CheckState(caster, "Casting") then
			task.wait(20)
			clone:Destroy()
		end
	end
end