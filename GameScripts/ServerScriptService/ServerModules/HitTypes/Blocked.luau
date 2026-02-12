--Defualt HitType

local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage.Assets
local modules = (replicatedStorage.Modules)
local stateService = require(modules.StateService)

local itemDataBase = require(modules.ItemDataBase)

return function(attacker:Model , targetHit:Model , weaponUsed:Tool?, playerDamageStat, targetDefenseStat, player, abilityData, npcDamage)
	local targetHumanoid:Humanoid = targetHit:FindFirstChild("Humanoid")
	if not targetHumanoid then return end
	if stateService.checkState(targetHit, "Invulnerable") then return end
	local damage
	if player then
		if abilityData then
			damage =  math.max(abilityData.Damage * (100/ (100 + targetDefenseStat)) * 0.1,
				math.floor(
					(( 1 + (abilityData.Damage) / 100) * playerDamageStat) * ( 100 / ( 100 + targetDefenseStat ))*0.1)) 
			targetHumanoid:TakeDamage(damage)

			replicatedStorage.Remotes.ClientEffects:FireAllClients("BlockedHit" , {
				["Target"] = targetHit ,
				["weaponUsed"] = weaponUsed,
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

				damage =  math.max(foundWeaponData.Damage * (100/ (100 + targetDefenseStat)) * 0.1,
					math.floor(
						(( 1 + (foundWeaponData.Damage) / 100) * playerDamageStat) * ( 100 / ( 100 + targetDefenseStat ))*0.1)) 
				targetHumanoid:TakeDamage(damage)

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
		replicatedStorage.Remotes.ShowDamage:FireClient(player, damage, false, true)
	else
		if abilityData then
			damage =  math.max(npcDamage * (100/ (100 + targetDefenseStat)) * 0.1,
				math.floor(
					(( 1 + (abilityData.Damage) / 100) * npcDamage) * ( 100 / ( 100 + targetDefenseStat ))*0.1)) 
			targetHumanoid:TakeDamage(damage)

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

				damage =  math.max(npcDamage * (100/ (100 + targetDefenseStat)) * 0.1,
					math.floor(
						(( 1 + (foundWeaponData.Damage) / 100) * npcDamage) * ( 100 / ( 100 + targetDefenseStat ))*0.1)) 
				targetHumanoid:TakeDamage(damage)

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
							local blockBreakAnim  = animator:LoadAnimation(assets.Animations.Character[weaponUsed.Name]["BlockShrug"..tostring(randomShrug)])
							blockBreakAnim:Play()
						end
					end
				end)
			end	
		end
	end
end