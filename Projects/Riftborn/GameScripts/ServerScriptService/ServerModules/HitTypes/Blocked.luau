--Defualt HitType

local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage.Assets
local modules = (replicatedStorage.Modules)
local stateService = require(modules.StateService)

local itemDataBase = require(modules.Data.ItemDataBase)

local formulaApplier = require(modules.FormulaApplier)

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


		replicatedStorage.Remotes.ClientEffects:FireAllClients("BlockedHit" , {
			["Target"] = targetHit ,
			["weaponUsed"] = weaponUsed.Name,
		})

		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound" , {
			["SoundName"] = "AbilityBlock",
			["Parent"] = targetHit.HumanoidRootPart
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

			replicatedStorage.Remotes.ClientEffects:FireAllClients("BlockedHit" , {
				["Target"] = targetHit ,
				["weaponUsed"] = weaponUsed.Name,
			})

			task.spawn(function()
				local randomShrug = math.random(1,2)
				if targetHit:FindFirstChild("Core") then
					local animationsModule = require(targetHit.Core.Animations)
					animationsModule.loadedAnimations["Character.BlockReactions."..weaponUsed.Name..".BlockShrug"..tostring(randomShrug)]:Play()

				else
					local animator: Animator = targetHumanoid:FindFirstChild("Animator")
					if animator then
						local blockBreakAnim  = animator:LoadAnimation(assets.Animations.Character[weaponUsed]["BlockShrug"..tostring(randomShrug)])
						blockBreakAnim:Play()
					end
				end
			end)
		end	
	end
	
	if player then
		if AbilityDamage then
			replicatedStorage.Remotes.ShowDamage:FireClient(player ,AbilityDamage, false, false)
		else
			replicatedStorage.Remotes.ShowDamage:FireClient(player ,M1Damage, false, false)
		end
	end
	
end

