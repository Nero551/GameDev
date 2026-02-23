--DefualtHit

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")
local stateService = require(replicatedStorage.Modules.StateService)
local DynamicLight = require(replicatedStorage.Modules.DynamicLight)

local assets = replicatedStorage:WaitForChild("Assets")

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
		
		while stateService.checkState(caster, "Casting") do
			task.wait(0.1)
		end
		
		if not stateService.checkState(caster, "Casting") then
			task.wait(20)
			clone:Destroy()
		end
	end
end