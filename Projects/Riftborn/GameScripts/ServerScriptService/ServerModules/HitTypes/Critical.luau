--Defualt HitType

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage.Assets

local modules = (replicatedStorage.Modules)
local stateService = require(modules.StateService)
local weaponDataModule = require(modules.ItemDataBase.WeaponData)

return function(attacker:Model , targetHit:Model , weaponUsed:Tool, comboStringNumber:number, lastHit:boolean, playerDamageStat, playerCriticalDamageStat, targetDefenseStat, player:Player, abilityData, npcDamage)
	local targetHumanoid:Humanoid = targetHit:WaitForChild("Humanoid")
	local targetHRP = targetHit:WaitForChild("HumanoidRootPart")
	local attackerHRP = attacker:WaitForChild("HumanoidRootPart")
	if not  targetHumanoid then return end
	if stateService.checkState(targetHit, "Invulnerable") then return end

	local M1Damage
	local AbilityDamage
	
	stateService.addState(attacker, "In Combat", 20)
	stateService.addState(targetHit, "In Combat", 20)
	
	if player then
		if abilityData then
			AbilityDamage = math.max(abilityData.Damage * (100/ (100 + targetDefenseStat)),
				math.floor(
					(( 1 + abilityData.Damage / 100) * playerDamageStat) * ( 100 / ( 100 + targetDefenseStat )))) * playerCriticalDamageStat
		end

		local foundWeaponData = weaponDataModule.Weapons[weaponUsed:GetAttribute("ID")]
		if  foundWeaponData then
			M1Damage = math.max(foundWeaponData.Damage * (100/ (100 + targetDefenseStat)),
				math.floor((
					(1+ foundWeaponData.Damage / 100) * playerDamageStat) * ( 100 / ( 100 + targetDefenseStat )))) * playerCriticalDamageStat
		end

	else
		if abilityData then
			AbilityDamage = math.max(npcDamage * (100 / (100 + targetDefenseStat)),
				math.floor(
					( 1 + abilityData.Damage / 100) * npcDamage) * ( 100 / ( 100 + targetDefenseStat ))) * playerCriticalDamageStat
		end


		local foundWeaponData = weaponDataModule.Weapons[weaponUsed:GetAttribute("ID")]

		if  foundWeaponData then
			M1Damage = math.max(npcDamage * (100/ (100 + targetDefenseStat)),
				math.floor(
					(1+ foundWeaponData.Damage / 100) * npcDamage) * ( 100 / ( 100 + targetDefenseStat ))) * playerCriticalDamageStat
		end	
	end	

	local killerHit:ObjectValue = targetHumanoid:FindFirstChild("KillerHit")
	if killerHit and killerHit.Value == player then
		killerHit:Destroy()
	end
	killerHit = Instance.new("ObjectValue")
	killerHit.Parent = targetHumanoid
	killerHit.Value = player
	killerHit.Name = "KillerHit"	
	debris:AddItem(killerHit, 30)

	if abilityData then
		targetHumanoid:TakeDamage(AbilityDamage)


		replicatedStorage.Remotes.ClientEffects:FireAllClients("DefualtHit" , {
			["Target"] = targetHit ,
			["weaponUsed"] = weaponUsed.Name,
		})


		if targetHit:FindFirstChild("Core") then
			local animationsModule = require(targetHit.Core.Animations)
			animationsModule.loadedAnimations["Character.HitReactions.AbilityHitReactions."..abilityData.HitReaction]:Play()
		else
			local animator: Animator = targetHumanoid:FindFirstChild("Animator")
			if animator then
				local HitReactionAnim  = animator:LoadAnimation(assets.Animations.Character.HitReactions.AbilityHitReactions[abilityData.HitReaction])
				HitReactionAnim:Play()
			end
		end

	else				
		stateService.addState(targetHit , "Stunned" , 0.4)

		targetHumanoid:TakeDamage(M1Damage)

		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound" , {
			["SoundName"] = "Weapons."..weaponUsed.Name..".Hit."..tostring(comboStringNumber) ,
			["Parent"] = targetHRP
		})

		replicatedStorage.Remotes.ClientEffects:FireAllClients("DefualtHit" , {
			["Target"] = targetHit ,
			["weaponUsed"] = weaponUsed.Name,
		})

		if targetHit:FindFirstChild("Core") then
			local animationsModule = require(targetHit.Core.Animations)
			local hitReactionAnim:AnimationTrack? = animationsModule.loadedAnimations["Character.HitReactions."..weaponUsed.Name.."."..tostring(comboStringNumber)]
			hitReactionAnim:Play()
			stateService.addState(targetHit , "Stunned" , hitReactionAnim.Length + 0.1)
		else
			local animator: Animator = targetHumanoid:FindFirstChild("Animator")
			if animator then
				local HitReactionAnim:AnimationTrack?  = animator:LoadAnimation(assets.Animations.Character["HitReactions"][weaponUsed.Name][tostring(comboStringNumber)])
				HitReactionAnim:Play()
				stateService.addState(targetHit , "Stunned" , HitReactionAnim.Length + 0.1)
			end
		end

		------Control KnockBack------
		if lastHit then

			------EndLag Setup------
			stateService.addState(attacker , "NoMove", .5)
			stateService.addState(attacker , "NoPunch", 1)

			local knockbackAttachment:Attachment = targetHRP:FindFirstChild("VelocityAttachment")
			if not knockbackAttachment then
				knockbackAttachment = Instance.new("Attachment")
				knockbackAttachment.Name = "KnockbackVelocityAttachment"
				knockbackAttachment.Parent = targetHRP
			end
			local knockbackVel = Instance.new("LinearVelocity")
			knockbackVel.Attachment0 = knockbackAttachment
			knockbackVel.RelativeTo = Enum.ActuatorRelativeTo.World
			knockbackVel.VectorVelocity = attacker.HumanoidRootPart.CFrame.LookVector * 90
			knockbackVel.MaxForce = math.huge
			knockbackVel.Parent = targetHRP
			debris:AddItem(knockbackVel, 0.15)

		else
			local knockbackAttachment:Attachment = targetHRP:FindFirstChild("VelocityAttachment")
			if not knockbackAttachment then
				knockbackAttachment = Instance.new("Attachment")
				knockbackAttachment.Name = "KnockbackVelocityAttachment"
				knockbackAttachment.Parent = targetHRP
			end

			local pullAttachment:Attachment = targetHRP:FindFirstChild("VelocityAttachment")
			if not pullAttachment then
				pullAttachment = Instance.new("Attachment")
				pullAttachment.Name = "PullVelocityAttachment"
				pullAttachment.Parent = attackerHRP
			end

			local knockbackVelocity = Instance.new("LinearVelocity")

			knockbackVelocity.Attachment0 = knockbackAttachment
			knockbackVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
			knockbackVelocity.MaxForce = math.huge
			knockbackVelocity.VectorVelocity = attacker.HumanoidRootPart.CFrame.LookVector*11
			knockbackVelocity.Parent = targetHRP
			debris:AddItem(knockbackVelocity, 0.13)

			local pullVelocity = Instance.new("LinearVelocity")
			pullVelocity.Attachment0 = pullAttachment
			pullVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
			pullVelocity.MaxForce = math.huge
			knockbackVelocity.VectorVelocity = attacker.HumanoidRootPart.CFrame.LookVector*11
			pullVelocity.Parent = attackerHRP
			debris:AddItem(pullVelocity, 0.13)
		end
	end	

	if player then
		if AbilityDamage then
			replicatedStorage.Remotes.ShowDamage:FireClient(player ,AbilityDamage, true, false)
		else
			replicatedStorage.Remotes.ShowDamage:FireClient(player ,M1Damage, true, false)
		end
	end

end