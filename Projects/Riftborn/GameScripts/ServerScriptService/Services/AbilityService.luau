local replicatedStorage = game:GetService("ReplicatedStorage")
local run = game:GetService("RunService")
local players = game:GetService("Players")
local debris = game:GetService("Debris")
local modules = replicatedStorage.Modules
local assets = replicatedStorage.Assets
local DataService = require(script.Parent.DataService)

local remotes = replicatedStorage.Remotes

local itemDataBase = require(modules.Data.ItemDataBase)
local abilityDataModule = require(modules.Data.AbilityData)


local stateService = require(modules.StateService)
local CharacterVitalsService = require(script.Parent.CharacterVitalsService)

local ActionVerifier = require(modules.ActionVerifier)
local HitApplier = require(script.Parent.Parent.Modules.Utilities.HitApplier)

local AbilityService = {
	hitTypes = {}
}

for _,module  in script.Parent.Parent.Modules.HitTypes:GetChildren() do
	if module:IsA("ModuleScript") then
		AbilityService.hitTypes[module.Name] = require(module)
	end
end


function AbilityService.AbilityUse(player:Player ,character, tool:Tool, mouse, input, letter, npcDamage)
	
	if not tool then return end
	
	local abilityletter = input or letter
			
	if not ActionVerifier:CanAbility(character, abilityletter) then return end
	
	local playerStats
	
	local humanoid:Humanoid = character:WaitForChild("Humanoid")
	local abilityData = abilityDataModule.getAbilityData(tool.Name,abilityletter)
	
	if not abilityData then
		print("Ability data not found for:", tool.Name..abilityletter)
		return
	end	
	
	local weaponData = itemDataBase:GetItemData(tool:GetAttribute("ID"))
	
	local animsFolder = assets.Weapons[tool.Name].Animations
	local sounds = assets.Shared.Sounds
	
	if player then
		playerStats = DataService:GetTable(player,"Stats")
		local playerMana = CharacterVitalsService:GetVital(character , "Mana")
		if playerMana.CurrentMana < abilityData.Mana  then
			sounds.Error:Play()
			remotes.PopUp:FireClient(player,
				{
					["AbilityName"] = abilityData.AbilityName,
					["RequiredMana"] = abilityData.Mana,
				}
			)
			return
		end
		playerMana.CurrentMana = playerMana.CurrentMana - abilityData.Mana
	end

	---CoolDown---
	local cooldownTime  = abilityData.AbilityCooldown

	---Animation---
	local animsModule = require(modules.Animations)
	local animation:AnimationTrack = animsModule:GetAnimation(humanoid.Animator, "Weapons."..tool.Name..".Animations.Abilities."..abilityletter)
	if not animation then warn("Animation Not Found") print(animsModule.loadedAnimations) return end
	animation:Play()
	
	---Ability States---
	stateService.addState(character,"Ability"..abilityletter.." Cooldown", cooldownTime)
	stateService.addState(character, "Invulnerable", animation.Length)
	stateService.addState(character, "Casting", animation.Length)

	animation:GetMarkerReachedSignal("Hit"):Once(function()
		local hrp:Part? = character:WaitForChild("HumanoidRootPart")

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
		remotes.ClientEffects:FireAllClients("AbilityVFX", {
			["VFX"] = assets.Weapons[tool.Name].Effects.Abilities[abilityletter],
			["HitBoxName"] = hitboxClone.Name,
			["Caster"] = character
		})
		
		---Sound---
		remotes.ClientEffects:FireAllClients("AbilitySound", {
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

					if stateService.checkState(targetHit, "Invulnerable") then continue end

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
		
		debris:AddItem(hitboxClone, 1)
	end)	
end

return AbilityService