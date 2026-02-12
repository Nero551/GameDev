--DashVFX

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

local assets = replicatedStorage:WaitForChild("Assets")
local effects = assets.Effects

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
		debris:AddItem(clone, dashTime)
	end	
end