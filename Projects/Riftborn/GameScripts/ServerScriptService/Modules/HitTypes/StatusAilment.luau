--StatusAilment HitType

local debris = game:GetService("Debris")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local assets = replicatedStorage.Assets

local modules = (replicatedStorage.Modules)
local stateService = require(modules.StateService)
local itemDataBase = require(modules.Data.ItemDataBase)
local knockbackPull = require(script.Parent.Parent.Utilities.KnockbackPull)
local formulaApplier = require(modules.FormulaApplier)
local animationsModule = require(modules.Animations)
local statusAilmentsData = require(modules.Data.StatusAilmentsData)

local AilmentService = require(script.Parent.Parent.Parent.Services.AilmentService)
local CharacterVitalsService = require(script.Parent.Parent.Parent.Services.CharacterVitalsService)


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
	local statusAilments = argumentData.StatusAilments
		
	local targetHumanoid:Humanoid = targetHit:WaitForChild("Humanoid")
	local animator = targetHumanoid:FindFirstChild("Animator")
	
	local targetHRP = targetHit:WaitForChild("HumanoidRootPart")
	local attackerHRP = attacker:WaitForChild("HumanoidRootPart")
	if not  targetHumanoid then return end
	if stateService.checkState(targetHit, "Invulnerable") then return end
	local M1Damage
	local AbilityDamage
	local ailmentDamage
	local ailmentName
	local ailmentData
	
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
	
	replicatedStorage.Remotes.ClientEffects:FireAllClients("DefaultHit" , {
		["Target"] = targetHit ,
		["WeaponUsed"] = weaponUsed.Name,
	})
	
	
	if abilityData then		
		AbilityDamage = formulaApplier:AbilityDamage({
			["AbilityData"] = abilityData,
			["TargetDefenseStat"] = targetDefenseStat,
			["PlayerDamageStat"] = playerDamageStat,
			["NPCDamage"] = npcDamage,	
		})
		
		print(AbilityDamage, -AbilityDamage)
		
		CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
			["HealthChange"] = -AbilityDamage

		})
		
		animationsModule:GetAnimation(
			animator, "Shared.Character.AbilityHitReactions."..abilityData.HitReaction
		):Play()
	else				
		local foundWeaponData = itemDataBase:GetItemData(weaponUsed:GetAttribute("ID")) 
		if foundWeaponData then
			M1Damage = formulaApplier:M1Damage({
				["NPCDamage"] = npcDamage,
				["PlayerDamageStat"] = playerDamageStat,
				["TargetDefenseStat"] = targetDefenseStat,
				["FoundWeaponData"] = foundWeaponData
				
			})
			
			CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
				["HealthChange"] = -M1Damage

			})
			

			replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound" , {
				["SoundName"] = "Weapons."..weaponUsed.Name..".Sounds.Hit."..tostring(comboStringNumber) ,
				["Parent"] = targetHRP
			})

			local hitReactionAnim = animationsModule:GetAnimation(
				animator, "Shared.Character.HitReactions."..tostring(comboStringNumber)
			)
			hitReactionAnim:Play()
			stateService.addState(targetHit , "Stunned" , hitReactionAnim.Length + 0.1)
		end	
		
		------Control KnockBack------
		if lastHit then

			------EndLag Setup------
			stateService.addState(attacker , "NoMove", .5)
			stateService.addState(attacker , "NoPunch", 1)
			
			knockbackPull:ApplyKnockback(targetHit,attacker,90)
		else
			knockbackPull:ApplyKnockback(targetHit, attacker, 11)
			knockbackPull:ApplyPull(targetHit,attacker,11)
			

		end
	end	
	
	if statusAilments then
		local randomAilment = math.random(1, #statusAilments)
		ailmentName = statusAilments[randomAilment]
		ailmentData = statusAilmentsData.Ailments[ailmentName]
		
		replicatedStorage.Remotes.ClientEffects:FireAllClients("AilmentHit",{
			["Target"] = targetHit,
			["Ailment"] = ailmentName,
			["Duration"] = ailmentData.BaseDuration,
			["State"] = ailmentData.State

		})

		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound",{
			["Parent"] = targetHRP,
			["SoundName"] = "Shared.Sounds.AilmentSounds."..ailmentName

		})
		
		
		AilmentService[ailmentName](AilmentService,attacker,targetHit, ailmentName, M1Damage or AbilityDamage)
	end

	
	if player then
		
		replicatedStorage.Remotes.Hitstop:FireClient(player ,0.03)
		
		if AbilityDamage then
			replicatedStorage.Remotes.ShowDamage:FireClient(player ,AbilityDamage, false,false, false, ailmentName, ailmentData)
		else
			replicatedStorage.Remotes.ShowDamage:FireClient(player ,M1Damage, false,false, false, ailmentName, ailmentData)
		end
	end

end