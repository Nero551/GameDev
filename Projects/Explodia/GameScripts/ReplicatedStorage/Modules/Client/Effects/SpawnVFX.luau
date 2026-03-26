local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function(arguementData:any)
	local character = arguementData.Character
	
	local spawnEffect = ReplicatedStorage.Assets.Shared.Core.Spawn.SpawnVFX:Clone()
	spawnEffect.Parent = workspace.World.Effects
	spawnEffect.Position = character:WaitForChild("Torso").Position +   Vector3.new(0,-2,0)
	spawnEffect.Orientation = character:WaitForChild("Torso").Orientation 
	for _, effect in spawnEffect:GetDescendants() do
		if effect:IsA("ParticleEmitter") then
			local emitCount = effect:GetAttribute("EmitCount")
			effect:Emit(emitCount)
		end
	end
	Debris:AddItem(spawnEffect, 4)
end