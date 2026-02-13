--FlashstepVFX

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

local assets = replicatedStorage:WaitForChild("Assets")
local effects = assets.Shared.Effects

return function(arguementData:any)
	local character = arguementData.Character
	
	local function Transparency(value)
		for _, part:Part? in character:GetDescendants() do

			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				if not part:GetAttribute("WeaponHandle") then

					if  part.Parent:GetAttribute("EquipState") ~= false then
						part.Transparency = value
					else
						part.Transparency = 1
					end
				end
			end	
		end
	end
	
	---Smoke---
	local smoke = effects.CoreEffects.FlashStepSmoke:Clone()
	smoke.Parent = workspace.World.Effects
	smoke.Position = character["Left Leg"].Position
	for _, particle in  ipairs(smoke:GetDescendants()) do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = true
		end	
	end	
	debris:AddItem(smoke, 0.1)

	---VFX--- 
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		local clone =  effects.CoreEffects.FlashStep:Clone()
		clone.Parent = rootPart
		for _,v in clone:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end

		end	
		debris:AddItem(clone, 1)
	end	
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
		debris:AddItem(smoke , 0.1)
	end)
end