--DashVFX

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage.Assets
local effects = assets.Shared.Effects

return function(arguementData:any)
	local direction = arguementData.Direction
	local character = arguementData.Character
	local dashTime = arguementData.DashTime
				
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		local clone =  effects.DashEffects[direction]:Clone()
		clone.Parent = rootPart
		local weld = Instance.new("Weld")
		weld.Part0 = character.HumanoidRootPart
		weld.Part1 = clone
		weld.Parent = clone

		--Add Effects--
		for _, effect:ParticleEmitter? in clone:GetDescendants() do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
			end
		end
		Debris:AddItem(clone, dashTime)
	end	
end