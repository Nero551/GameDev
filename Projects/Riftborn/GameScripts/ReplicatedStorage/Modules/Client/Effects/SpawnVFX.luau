--SpawnVFX

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")

local assets = replicatedStorage:WaitForChild("Assets")
local effects = assets.Shared.Effects

return function(arguementData:any)
	local character = arguementData.Character
	
	local spawnEffect = effects.CoreEffects.SpawnVFX:Clone()
	spawnEffect.Parent = workspace.World.Effects
	spawnEffect.Position = character:WaitForChild("Torso").Position +   Vector3.new(0,-2,0)
	spawnEffect.Orientation = character:WaitForChild("Torso").Orientation 
	for _, effect:ParticleEmitter? in spawnEffect:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			local emitCount = effect:GetAttribute("EmitCount")
			effect:Emit(emitCount)
		end
	end
end