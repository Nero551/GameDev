local replicatedStorage = game:GetService("ReplicatedStorage")
local run = game:GetService("RunService")
local players = game:GetService("Players")
local debris = game:GetService("Debris")
local modules = replicatedStorage.Modules
local assets = replicatedStorage.Assets
local DataService = require(script.Parent.DataService)

local animsFolder = assets.Animations
local sounds = assets.Sounds
local remotes = replicatedStorage.Remotes

local itemDataBase = require(modules.ItemDataBase)
local abilityDataModule = require(modules.AbilityData)


local stateService = require(modules.StateService)
local ManaService = require(script.Parent.ManaService)
local ActionVerifier = require(modules.ActionVerifier)

local weaponType= {
	hitTypes = {}
}

for _,module  in script.Parent.Parent.ServerModules.HitTypes:GetChildren() do
	if module:IsA("ModuleScript") then
		weaponType.hitTypes[module.Name] = require(module)
	end
end

local ability = {
	
}

function ability.AbilityUse(player:Player ,character, tool:Tool, mouse, input, abilityData, letter, npcDamage)
	
	
	local abilityletter = input or letter
	
	print(abilityletter)
		
	if not ActionVerifier:CanAbility(character, abilityletter) then return end
	
	local playerStats
	
	local humanoid:Humanoid = character:WaitForChild("Humanoid")
	local abilityData = abilityDataModule.getAbilityData(tool.Name..abilityletter)
	
	if not abilityData then return end
	
	local weaponData = itemDataBase:GetItemData(tool:GetAttribute("ID"))

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
	local animsModule = require(character:WaitForChild("Core").Animations)
	animsModule.loadAnims(humanoid.Animator, animsFolder)
	local animation:AnimationTrack = animsModule.loadedAnimations[abilityData.Animation]
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
		local params = OverlapParams.new()
		if abilityData.OnMouse == true then

			hitboxClone.Name = abilityData.AbilityName.." Hitbox"
			hitboxClone.Size = abilityData.HitBoxSize
			hitboxClone.Position = mouse
			hitboxClone.Parent = workspace.World.Hitboxes
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {character , workspace.World.Hitboxes}
		else
			hitboxClone.Name = abilityData.AbilityName.." Hitbox"
			hitboxClone.Size = abilityData.HitBoxSize
			hitboxClone.Position = hrp.Position + abilityData.HitBoxPosition + hrp.CFrame.LookVector * abilityData.HitBoxLookVector
			hitboxClone.Orientation = hrp.Orientation + abilityData.HitBoxRotation
			hitboxClone.Parent = workspace.World.Hitboxes
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {character , workspace.World.Hitboxes}
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
		local hit = {}
		local partsCollected = workspace:GetPartsInPart(hitboxClone , params)
		for _, part in partsCollected do 
			if part.Parent and part.Parent:FindFirstChild("Humanoid") then
				local targetHit = part.Parent

				if stateService.checkState(targetHit, "Invulnerable") then return end


				local targetHumanoid:Humanoid = targetHit:FindFirstChild("Humanoid")
				if targetHumanoid and not hit[targetHumanoid] then
					hit[targetHumanoid] = true

					task.spawn(function()
						local targetDefenseStat = 0
						if players:GetPlayerFromCharacter(targetHit) then
							targetDefenseStat = DataService:GetTable(players:GetPlayerFromCharacter(targetHit), "Stats").Defense.Final
						end
						
						local playerDamageStat
						local playerCriticalDamageStat
						local playerCriticalRateStat

						if player then
							playerDamageStat = playerStats[players:GetPlayerFromCharacter(character)][weaponData.Type].Final
							playerCriticalDamageStat = playerStats[players:GetPlayerFromCharacter(character)].CriticalDamage.Percent + weaponData.CriticalDamage + 1
							playerCriticalRateStat = ((playerStats[players:GetPlayerFromCharacter(character)].CriticalRate.Percent) + weaponData.CriticalRate) * 100
						end	

						local blockCounter = targetHit:WaitForChild("Status"):FindFirstChild("BlockCounter")
						for Hit = 1, abilityData.Hits , 1 do
							if stateService.checkState(targetHit, "Blocking") then

								---Do BlockBreak---
								if blockCounter.Value == 4 or abilityData.BlockBreak == true then
									blockCounter.Value = 0
									blockCounter.Value = math.clamp(blockCounter.Value, 0 , 4)
									weaponType.hitTypes["BlockBreak"](character , targetHit , tool)
								else

									---Do Blocked HitType---
									blockCounter.Value += abilityData.BlockDetoriation
									blockCounter.Value = math.clamp(blockCounter.Value, 0 , 4)
									weaponType.hitTypes["Blocked"](character, targetHit, tool ,playerDamageStat,
										targetDefenseStat, player , abilityData, npcDamage)

								end	
							else
								---Critical HitType---
								if playerCriticalDamageStat and playerCriticalRateStat then
									if math.random(0 , 100) <= playerCriticalRateStat then
										weaponType.hitTypes["Critical"](character, targetHit, tool, nil, nil, playerDamageStat,
											playerCriticalDamageStat , targetDefenseStat, player, abilityData, npcDamage)
									end
								else	
									---Do Default HitType---
									weaponType.hitTypes["Default"](character, targetHit, tool, nil, nil, playerDamageStat,
										targetDefenseStat, player, abilityData, npcDamage)
								end

							end
							task.wait(abilityData.TimeBtwnHits)				
						end	
					end)

				end
			end
		end
		debris:AddItem(hitboxClone, 1)
	end)	
end

return ability