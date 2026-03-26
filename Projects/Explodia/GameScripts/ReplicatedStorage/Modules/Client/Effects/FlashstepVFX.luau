local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function(arguementData:any)
	local character = arguementData.Character
	
	local function Transparency(value)
		for _, part in character:GetDescendants() do
			
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and not
			 part:GetAttribute("StatusEffect") and not
			 part:GetAttribute("Ailment") and not
			 part:GetAttribute("WeaponHandle")  then

				if  part.Parent:GetAttribute("EquipState") ~= false then
					part.Transparency = value
				else
					part.Transparency = 1
				end
			end	
		end
	end
	
	---VFX--- 
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		local clone =  ReplicatedStorage.Assets.Shared.Movement.Flashstep.VFX:Clone()
		clone.Parent = rootPart
		for _,v in clone:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end

		end	
		Debris:AddItem(clone, 1)
	end
	
	---Smoke---
	local smoke = ReplicatedStorage.Assets.Shared.Movement.Flashstep.Smoke:Clone()
	smoke.Parent = workspace.World.Effects
	smoke.Position = character["Left Leg"].Position
	for _, particle in  ipairs(smoke:GetDescendants()) do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = true
		end	
	end	
	Debris:AddItem(smoke, 0.1)
	
	Transparency(1)
	task.delay(1, function()
		Transparency(0)
		---Smoke---
		smoke.Position = character["Right Leg"].Position
		for _, particle in  ipairs(smoke:GetDescendants()) do
			if particle:IsA("ParticleEmitter") then
				particle.Enabled = true
			end
		end
		Debris:AddItem(smoke , 0.1)
	end)
end
