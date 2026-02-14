--Defualt HitType

local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage.Assets
local modules = (replicatedStorage.Modules)
local stateService = require(modules.StateService)

local itemDataBase = require(modules.Data.ItemDataBase)

local formulaApplier = require(modules.FormulaApplier)
local animationsModule = require(modules.Animations)


return function(argumentData)
	
	local targetHit = argumentData.TargetHit
	local abilityData = argumentData.AbilityData
	local weaponUsed = argumentData.WeaponUsed
	local targetDefenseStat = argumentData.TargetDefenseStat
	local playerDamageStat = argumentData.PlayerDamageStat
	local npcDamage = argumentData.NPCDamage
	local player = argumentData.Player
	
	local targetHumanoid:Humanoid = targetHit:FindFirstChild("Humanoid")
	if not targetHumanoid then return end
	local animator = targetHumanoid:FindFirstChild("Animator")
	
	if stateService.checkState(targetHit, "Invulnerable") then return end
	local M1Damage
	local AbilityDamage
	
	if abilityData then
		AbilityDamage = formulaApplier:AbilityDamage({
			["AbilityData"] = abilityData,
			["TargetDefenseStat"] = targetDefenseStat,
			["PlayerDamageStat"] = playerDamageStat,
			["NPCDamage"] = npcDamage,	
			["Blocked"] = true
		})
		targetHumanoid:TakeDamage(AbilityDamage)

		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound" , {
			["SoundName"] = "AbilityBlock",
			["Parent"] = targetHit.HumanoidRootPart
		})
	else
		local foundWeaponData = itemDataBase:GetItemData(weaponUsed:GetAttribute("ID"))
		if  foundWeaponData then
			
			M1Damage = formulaApplier:M1Damage({
				["NPCDamage"] = npcDamage,
				["PlayerDamageStat"] = playerDamageStat,
				["TargetDefenseStat"] = targetDefenseStat,
				["FoundWeaponData"] = foundWeaponData,
				["Blocked"] = true,

			})			targetHumanoid:TakeDamage(M1Damage)

			local randomNumber =  math.random(1,4)
			replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound" , {
				["SoundName"] = "Weapons."..weaponUsed.Name..".Blocked."..tostring(randomNumber) ,
				["Parent"] = targetHit.HumanoidRootPart
			})
		end	
	end
	
	replicatedStorage.Remotes.ClientEffects:FireAllClients("BlockedHit" , {
		["Target"] = targetHit ,
		["weaponUsed"] = weaponUsed.Name,
	})
	
	task.spawn(function()
		local randomShrug = math.random(1,2)
		animationsModule:GetAnimation(animator, "Weapons."..weaponUsed.Name..".Character.BlockReactions.BlockShrug"..tostring(randomShrug)):Play()
	end)
	
	if player then
		if AbilityDamage then
			replicatedStorage.Remotes.ShowDamage:FireClient(player ,AbilityDamage, false, false)
		else
			replicatedStorage.Remotes.ShowDamage:FireClient(player ,M1Damage, false, false)
		end
	end
	
end

