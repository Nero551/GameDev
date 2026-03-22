--DashVFX

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assets = ReplicatedStorage.Assets
local effects = assets.Shared.Effects

return function(arguementData:any)
	local direction = arguementData.Dir
	local rootPart = arguementData.HRP
	local dashTime = arguementData.DashT
				
	if rootPart then
		local clone =  effects.DashEffects[direction]:Clone()
		clone.Parent = rootPart
		local weld = Instance.new("Weld")
		weld.Part0 = rootPart
		weld.Part1 = clone
		weld.Parent = clone

		--Add Effects--
		for _, effect:ParticleEmitter in clone:GetDescendants() do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
			end
		end
		Debris:AddItem(clone, dashTime)
	end	
end