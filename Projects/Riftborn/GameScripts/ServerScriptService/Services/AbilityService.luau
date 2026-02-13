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
local ManaService = require(script.Parent.ManaService)
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

local ability = {
	
}

function ability.AbilityUse(player:Player ,character, tool:Tool, mouse, input, abilityData, letter, npcDamage)
	
	
	local abilityletter = input or letter
			
	if not ActionVerifier:CanAbility(character, abilityletter) then return end
	
	local playerStats
	
	local humanoid:Humanoid = character:WaitForChild("Humanoid")
	local abilityData = abilityDataModule.getAbilityData(tool.Name..abilityletter)
	
	if not abilityData then return end
	
	local weaponData = itemDataBase:GetItemData(tool:GetAttribute("ID"))
	
	local animsFolder = assets.Weapons[tool.Name].Animations
	local sounds = assets.Shared.Sounds
	
	if player then
		playerStats = DataService:GetTable(player,"Stats")
		local playerMana = DataService:GetTable(player, "Mana")
		if playerMana.CurrentMana < abilityData.Mana  then
			sounds.Error:Play()
			remotes.PopUp:FireClient(player,
				{
					["AbilityName"] = abilityData.AbilityName,
				}
			)
			warn("Not Enough Mana For "..abilityData.AbilityName)
			return
		end
		playerMana.CurrentMana = playerMana.CurrentMana - abilityData.Mana
		ManaService:UpdateMana(player, playerMana,playerStats)
	end


	if not abilityData then
		print("Ability data not found for:", tool.Name..abilityletter)
		return
	end

	---CoolDown---
	local cooldownTime  = abilityData.AbilityCooldown

	---Animation---
	local animsModule = require(modules.Animations)
	animsModule:loadAnims(humanoid.Animator, animsFolder)
	local animation:AnimationTrack = animsModule.loadedAnimations[character.Name][abilityData.Animation]
	if not animation then warn("Animation Not Found") return end
	animation:Play()
	
	
	---Ability States---
	stateService.addState(character,"Ability"..abilityletter.." Cooldown", cooldownTime)
	stateService.addState(character, "Invulnerable", animation.Length)
	stateService.addState(character, "Casting", animation.Length)
	stateService.addState(character , "Stunned", animation.Length)


	animation:GetMarkerReachedSignal("Hit"):Connect(function()
		local hrp:Part? = character:WaitForChild("HumanoidRootPart")

		---HitBox---
		local hitboxClone = assets.HItboxTemplate:Clone()
		if abilityData.OnMouse == true then

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
		local vfx:Attachment = abilityData.VFX:Clone() 
		vfx.Parent = workspace.World.Effects
		vfx.CFrame = hitboxClone.CFrame
		for _,child:ParticleEmitter? in vfx:GetDescendants() do
			if child:IsA("ParticleEmitter") then
				local emitCount = child:GetAttribute("EmitCount")
				child:Emit(emitCount)
			end
		end
		debris:AddItem(vfx, 5)

		---Sound---
		local sound:Sound? = abilityData.Sound:Clone()
		sound.Parent = workspace.World.Effects
		sound.RollOffMaxDistance = 50
		sound.RollOffMode = Enum.RollOffMode.Linear
		if sound then
			sound:Play()
			debris:AddItem(sound, sound.TimeLength)
		end

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

					if stateService.checkState(targetHit, "Invulnerable") then return end


					local targetHumanoid:Humanoid = targetHit:FindFirstChild("Humanoid")
					if targetHumanoid and not hit[targetHumanoid] then
						hit[targetHumanoid] = true

						HitApplier:ApplyHit({
							["Player"] = player,
							["WeaponData"] = weaponData,
							["TargetHit"] = targetHit,
							["Tool"] = tool,
							["NPCDamage"] = npcDamage,
							["HitTypes"] = AbilityService.hitTypes,
							["Character"] = character,
							["AbilityData"] = abilityData
						})

					end
				end
			end
		end)
		
		debris:AddItem(hitboxClone, 1)
	end)	
end

return ability