--Defualt HitType

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage.Assets

local modules = (replicatedStorage.Modules)
local stateService = require(modules.StateService)
local itemDataBase = require(modules.Data.ItemDataBase)
local knockbackPull = require(script.Parent.Parent.Utilities.KnockbackPull)
local formulaApplier = require(modules.FormulaApplier)

return function(argumentData)
	
	local targetHit = argumentData.TargetHit
	local attacker = argumentData.Attacker
	local player = argumentData.Player
	local abilityData = argumentData.AbilityData
	local weaponUsed = argumentData.WeaponUsed
	local targetDefenseStat = argumentData.TargetDefenseStat
	local playerDamageStat = argumentData.PlayerDamageStat
	local npcDamage = argumentData.NPCDamage
	local comboStringNumber = argumentData.ComboStringNumber
	local lastHit = argumentData.LastHit
	local playerCriticalDamageStat = argumentData.PlayerCriticalDamageStat
	
	local targetHumanoid:Humanoid = targetHit:WaitForChild("Humanoid")
	local targetHRP = targetHit:WaitForChild("HumanoidRootPart")
	local attackerHRP = attacker:WaitForChild("HumanoidRootPart")
	if not  targetHumanoid then return end
	if stateService.checkState(targetHit, "Invulnerable") then return end

	local M1Damage
	local AbilityDamage
	
	stateService.addState(attacker, "In Combat", 20)
	stateService.addState(targetHit, "In Combat", 20)
	
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
		
		AbilityDamage = formulaApplier:AbilityDamage({
			["AbilityData"] = abilityData,
			["TargetDefenseStat"] = targetDefenseStat,
			["PlayerDamageStat"] = playerDamageStat,
			["PlayerCriticalDamageStat"] = playerCriticalDamageStat,
			["NPCDamage"] = npcDamage,	
		})
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
		
		local foundWeaponData = itemDataBase:GetItemData(weaponUsed:GetAttribute("ID")) 
		if foundWeaponData then
			M1Damage = formulaApplier:M1Damage({
				["NPCDamage"] = npcDamage,
				["PlayerDamageStat"] = playerDamageStat,
				["TargetDefenseStat"] = targetDefenseStat,
				["FoundWeaponData"] = foundWeaponData,
				["PlayerCriticalDamageStat"] = playerCriticalDamageStat

			})			targetHumanoid:TakeDamage(M1Damage)

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
		end
		
		------Control KnockBack------
		if lastHit then

			------EndLag Setup------
			stateService.addState(attacker , "NoMove", .5)
			stateService.addState(attacker , "NoPunch", 1)
			------EndLag Setup------
			stateService.addState(attacker , "NoMove", .5)
			stateService.addState(attacker , "NoPunch", 1)

			knockbackPull:ApplyKnockback(targetHit,attacker,90)
		else
			knockbackPull:ApplyKnockback(targetHit, attacker, 11)
			knockbackPull:ApplyPull(targetHit,attacker,11)


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