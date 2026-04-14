local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Animations = require(ReplicatedStorage.Modules.Core.Animations)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local HitService = require(ServerScriptService.Services.Combat.HitService)
local StateService = require(ServerScriptService.Services.Core.StateService)
return function(character, techniqueSlot, techniqueData, mouse)
	local humanoid = character:WaitForChild("Humanoid")
	---Animation---
	local animation = Animations:GetAnimation(humanoid, "Techniques." .. techniqueData.TechniqueName .. ".Animation")
	if not animation then
		warn("Animation Not Found")
		return
	end
	animation:Play()

	---Ability States---
	StateService:AddState(character, "Technique" .. techniqueSlot .. " Cooldown", techniqueData.Cooldown)
	StateService:AddState(character, "Invulnerable", 0.2)
	StateService:AddState(character, "Casting", animation.Length)
	StateService:AddState(character, "MouseAiming")

	animation:GetMarkerReachedSignal("Hit"):Once(function()
		StateService:RemoveState(character, "MouseAiming")

		---HitBox---
		local hitboxClone = ReplicatedStorage.Assets.HitboxTemplate:Clone()
		if mouse then
			hitboxClone.Name = techniqueData.TechniqueName .. " Hitbox"
			hitboxClone.Size = techniqueData.HitBoxSize
			hitboxClone.Position = mouse
			hitboxClone.Parent = workspace.World.Hitboxes
		end

		---VFX---
		NetworkingService:FireInRange("ClientEffects", hitboxClone.Position, nil, "TechniqueVFX", {
			["VFX"] = ReplicatedStorage.Assets.Techniques[techniqueData.TechniqueName].VFX,
			["HitBoxName"] = hitboxClone.Name,
			["Caster"] = character,
		})

		---Sound---
		NetworkingService:FireInRange("ClientEffects", hitboxClone.Position, nil, "TechniqueSound", {
			["Sound"] = ReplicatedStorage.Assets.Techniques[techniqueData.TechniqueName].Activate,
			["HitBoxName"] = hitboxClone.Name,
		})
		Debris:AddItem(hitboxClone, animation.Length)

		---Damage---
		HitService:Apply(character, techniqueData, hitboxClone)
	end)
end
