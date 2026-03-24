local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
--Defualt HitType
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateService = require(game.ServerScriptService.Services.Core.StateService)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local KnockbackPull = require(game.ServerScriptService.Modules.Utilities.KnockbackPull)
local FormulaApplier = require(game.ReplicatedStorage.Modules.Helpers.FormulaApplier)
local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)

local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)

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
	local abilityLetter = argumentData.AbilityLetter

	local targetHumanoid:Humanoid = targetHit:WaitForChild("Humanoid")
	local animator = targetHumanoid:FindFirstChild("Animator")
	
	local targetHRP = targetHit:WaitForChild("HumanoidRootPart")
	if not  targetHumanoid then return end
	if StateChecker:CheckState(targetHit, "Invulnerable") then return end

	local M1Damage
	local AbilityDamage
	
	StateService:AddState(attacker, "In Combat", 20)
	StateService:AddState(targetHit, "In Combat", 20)
	
	local killerHit = targetHumanoid:FindFirstChild("KillerHit")
	if killerHit and killerHit.Value == player then
		killerHit:Destroy()
	end
	killerHit = Instance.new("ObjectValue")
	killerHit.Parent = targetHumanoid
	killerHit.Value = player
	killerHit.Name = "KillerHit"	
	Debris:AddItem(killerHit, 30)
	
	
	
	NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit" , {
		["Target"] = targetHit ,
		["Weapon"] = weaponUsed,
	})
	
--[[	NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "CriticalHit" , {
		["Target"] = targetHit ,
		["WeaponUsed"] = weaponUsed.Name,
	})
]]	
	if abilityData then
		AbilityDamage = FormulaApplier:AbilityDamage({
			["AbilityData"] = abilityData,
			["TargetDefenseStat"] = targetDefenseStat,
			["PlayerDamageStat"] = playerDamageStat,
			["PlayerCriticalDamageStat"] = playerCriticalDamageStat,
			["NPCDamage"] = npcDamage,	
		})
		
		CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
			["HealthChange"] = -AbilityDamage
			
		})
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Weapons
				:FindFirstChild(weaponUsed.Name).Sounds.Abilties.Hit
				:FindFirstChild(tostring(abilityLetter)),
			["Parent"] = targetHRP,
		})
		
		Animations:GetAnimation(
			animator, "Shared.Character.AbilityHitReactions."..abilityData.HitReaction
		):Play()
		StateService:AddState(targetHit, "Stunned", 0.2)

	else
		
		local foundWeaponData = ItemDataBase:GetItemData(weaponUsed:GetAttribute("ID")) 
		if foundWeaponData then
			M1Damage = FormulaApplier:M1Damage({
				["NPCDamage"] = npcDamage,
				["PlayerDamageStat"] = playerDamageStat,
				["TargetDefenseStat"] = targetDefenseStat,
				["FoundWeaponData"] = foundWeaponData,
				["PlayerCriticalDamageStat"] = playerCriticalDamageStat

			})
			
			CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
				["HealthChange"] = -M1Damage

			})

			NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
				["Sound"] = ReplicatedStorage.Assets.Weapons
					:FindFirstChild(weaponUsed.Name).Sounds.Hit
					:FindFirstChild(tostring(comboStringNumber)),
				["Parent"] = targetHRP,
				["Volume"] = 2,
			})


			local hitReactionAnim = Animations:GetAnimation(
				animator, "Shared.Character.HitReactions."..tostring(comboStringNumber)
			)
			hitReactionAnim:Play()
			StateService:AddState(targetHit , "Stunned" , hitReactionAnim.Length + 0.1)
		end
		
		------Control KnockBack------
		if lastHit then

			------EndLag Setup------
			StateService:AddState(attacker , "NoMove", .5)
			StateService:AddState(attacker , "NoPunch", 1)

			KnockbackPull:ApplyKnockback(targetHit,attacker,90)
		else
			KnockbackPull:ApplyKnockback(targetHit, attacker, 11)
			KnockbackPull:ApplyPull(targetHit,attacker,11)
		end	
	end	

	if player then
		NetworkingService:FireToClient(player , "Hitstop", 0.06)
		
		if AbilityDamage then
			NetworkingService:FireToClient(player , "ShowDamage", AbilityDamage, true, false)
		else
			NetworkingService:FireToClient(player , "ShowDamage", M1Damage, true, false)
		end
	end

end
