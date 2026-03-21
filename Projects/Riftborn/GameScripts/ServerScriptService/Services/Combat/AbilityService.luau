local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local NetworkingService = ModuleLoader:Load("Shared", "NetworkingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local modules = ReplicatedStorage.Modules
local assets = ReplicatedStorage.Assets


local ItemDataBase = ModuleLoader:Load("Shared", "ItemDataBase")
local AbilityData = ModuleLoader:Load("Shared", "AbilityData")

local StateService = ModuleLoader:Load("Server", "StateService")
local StateChecker = ModuleLoader:Load("Shared", "StateChecker")
local CharacterVitalsService = ModuleLoader:Load("Server", "CharacterVitalsService")

local ActionVerifier = ModuleLoader:Load("Shared", "ActionVerifier")
local HitApplier = ModuleLoader:Load("Server", "HitApplier")

local AbilityService = {
	hitTypes = {}
}

for _,module  in game.ServerScriptService.Modules.HitTypes:GetChildren() do
	if module:IsA("ModuleScript") then
		AbilityService.hitTypes[module.Name] = ModuleLoader:Load("Server", module.Name)
	end
end

function AbilityService:UseAbility(player:Player? ,character, tool:Tool, mouse, input, letter, npcDamage)
	
	if not tool then return end
	
	local abilityletter = input or letter
			
	if not ActionVerifier:CanAbility(character, abilityletter) then return end
	
	
	local humanoid = character:WaitForChild("Humanoid")
	local abilityData = AbilityData:GetAbilityData(tool.Name,abilityletter)
	
	if not abilityData then
		print("Ability data not found for:", tool.Name..abilityletter)
		return
	end	
	
	local weaponData = ItemDataBase:GetItemData(tool:GetAttribute("ID"))
	
	local sounds = assets.Shared.Sounds
	
	if player then
		local playerMana = CharacterVitalsService:GetVital(character , "Mana")
		if playerMana.CurrentMana < abilityData.Mana  then
			sounds.Error:Play()
			NetworkingService:FireToClient(player, "PopUp",
				{
					["AbilityName"] = abilityData.AbilityName,
					["RequiredMana"] = abilityData.Mana,
				}
			)
			return
		end
		NetworkingService:FireToClient(player, "CameraShake", 0.25)
		playerMana.CurrentMana = playerMana.CurrentMana - abilityData.Mana
	end

	---CoolDown---
	local cooldownTime  = abilityData.AbilityCooldown

	---Animation---
	local Animations = ModuleLoader:Load("Shared", "Animations")
	local animation:AnimationTrack = Animations:GetAnimation(humanoid.Animator, "Weapons."..tool.Name..".Animations.Abilities."..abilityletter)
	if not animation then
		 warn("Animation Not Found")
		  print(Animations.loadedAnimations) 
		  return 
	end
	animation:Play()
	
	---Ability States---
	StateService:AddState(character,"Ability"..abilityletter.." Cooldown", cooldownTime)
	StateService:AddState(character, "Invulnerable", animation.Length)
	StateService:AddState(character, "Casting", animation.Length)
	

	animation:GetMarkerReachedSignal("Hit"):Once(function()
		local hrp = character:WaitForChild("HumanoidRootPart")

		---HitBox---
		local hitboxClone = assets.HitboxTemplate:Clone()
		if abilityData.OnMouse and mouse then

			hitboxClone.Name = abilityData.AbilityName.." Hitbox"
			hitboxClone.Size = abilityData.HitBoxSize
			hitboxClone.Position = mouse
			hitboxClone.Parent = workspace.World.Hitboxes
		else
			hitboxClone.Name = abilityData.AbilityName.." Hitbox"
			hitboxClone.Size = abilityData.HitBoxSize
			hitboxClone.Position = hrp.Position + abilityData.HitBoxPosition + hrp.CFrame.LookVector * abilityData.HitBoxLookVector
			hitboxClone.Orientation = hrp.Orientation + abilityData.HitBoxRotation
			hitboxClone.Parent = workspace.World.Hitboxes

		end

		---VFX---	
		NetworkingService:FireInRange("ClientEffects", hitboxClone.Position, nil, "AbilityVFX", {
			["VFX"] = assets.Weapons[tool.Name].Effects.Abilities[abilityletter],
			["HitBoxName"] = hitboxClone.Name,
			["Caster"] = character
		})
		
		---Sound---
		NetworkingService:FireInRange("ClientEffects", hitboxClone.Position, nil, "AbilitySound", {
			["SoundName"] = "Weapons."..tool.Name..".Sounds.Abilities.Activate."..abilityletter,	
			["HitBoxName"] = hitboxClone.Name,
		})

		---Damage---
		task.spawn(function()
			local params = OverlapParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {character , workspace.World.Hitboxes}

			local hit = {}
			local partsCollected = workspace:GetPartsInPart(hitboxClone , params)
			for _, part in partsCollected do 
				if part.Parent and part.Parent:FindFirstChild("Humanoid") then
					local targetHit = part.Parent

					if StateChecker:CheckState(targetHit, "Invulnerable") then continue end

					local targetHumanoid:Humanoid = targetHit:FindFirstChild("Humanoid")
					if targetHumanoid and not hit[targetHumanoid] then
						hit[targetHumanoid] = true
						for Hit = 0, abilityData.Hits, 1 do
							HitApplier:ApplyHit({
								["Player"] = player,
								["WeaponData"] = weaponData,
								["TargetHit"] = targetHit,
								["Tool"] = tool,
								["NPCDamage"] = npcDamage,
								["HitTypes"] = AbilityService.hitTypes,
								["Character"] = character,
								["AbilityData"] = abilityData,
								["AbilityLetter"] = abilityletter,
							})
							task.wait(abilityData.TimeBtwnHits)
						end
					end
				end
			end
		end)
		
		Debris:AddItem(hitboxClone, 1)
	end)	
end

return AbilityService
