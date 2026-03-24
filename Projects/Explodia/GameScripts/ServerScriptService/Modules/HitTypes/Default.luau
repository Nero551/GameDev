local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
--Defualt HitType
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CombatUtils = require(ServerScriptService.Modules.Utilities.CombatUtils)
local StateService = require(game.ServerScriptService.Services.Core.StateService)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local FormulaApplier = require(game.ReplicatedStorage.Modules.Helpers.FormulaApplier)
local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)

local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

return function(argumentData)
	local targetHit = argumentData.TargetHit
	local attacker = argumentData.Attacker
	local abilityData = argumentData.AbilityData
	local weaponUsed = argumentData.WeaponUsed
	local targetDefenseStat = argumentData.TargetDefenseStat
	local playerDamageStat = argumentData.PlayerDamageStat
	local comboStringNumber = argumentData.ComboStringNumber
	local lastHit = argumentData.LastHit
	local abilityLetter = argumentData.AbilityLetter

	local targetHumanoid: Humanoid = targetHit:WaitForChild("Humanoid")
	local targetHRP = targetHit:WaitForChild("HumanoidRootPart")
	if not targetHumanoid then
		return
	end
	if StateChecker:CheckState(targetHit, "Invulnerable") then
		return
	end

	local M1Damage
	local AbilityDamage

	StateService:AddState(attacker, "In Combat", 20)
	StateService:AddState(targetHit, "In Combat", 20)



	NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit", {
		["T"] = targetHit,
		["W"] = weaponUsed,
	})

	if abilityData then
		AbilityDamage = FormulaApplier:AbilityDamage({
			["AbilityData"] = abilityData,
			["TargetDefenseStat"] = targetDefenseStat,
			["PlayerDamageStat"] = playerDamageStat,
		})

		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Weapons
				:FindFirstChild(weaponUsed.Name).Sounds.Abilities.Hit
				:FindFirstChild(tostring(abilityLetter)),
			["Parent"] = targetHRP,
		})

		VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
			["HealthChange"] = -AbilityDamage,
		})

		Animations:GetAnimation(targetHumanoid, "Shared.Character.AbilityHitReactions." .. abilityData.HitReaction):Play()

		StateService:AddState(targetHit, "Stunned", 0.2)
	else
		local foundWeaponData = ItemDataBase:GetItemData(weaponUsed:GetAttribute("ID"))
		if foundWeaponData then
			M1Damage = FormulaApplier:M1Damage({
				["PlayerDamageStat"] = playerDamageStat,
				["TargetDefenseStat"] = targetDefenseStat,
				["FoundWeaponData"] = foundWeaponData,
			})

			VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
				["HealthChange"] = -M1Damage,
			})

			NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
				["Sound"] = ReplicatedStorage.Assets.Weapons
					:FindFirstChild(weaponUsed.Name).Sounds.Hit
					:FindFirstChild(tostring(comboStringNumber)),
				["Parent"] = targetHRP,
			})

			local hitReactionAnim =
				Animations:GetAnimation(targetHumanoid, "Shared.Character.HitReactions." .. tostring(comboStringNumber))
			hitReactionAnim:Play()
			StateService:AddState(targetHit, "Stunned", hitReactionAnim.Length + 0.1)
		end

		------Control KnockBack------
		if lastHit then
			StateService:AddState(attacker, "NoMove", 0.5)
			StateService:AddState(attacker, "NoPunch", 1)

			CombatUtils:ApplyKnockback(targetHit, attacker, 90)
		else
			CombatUtils:ApplyKnockback(targetHit, attacker, 11)
			CombatUtils:ApplyPull(targetHit, attacker, 11)
		end
	end

	local playerAttacker = Players:GetPlayerFromCharacter(attacker)
	if playerAttacker then
		NetworkingService:FireToClient(playerAttacker, "Hitstop", 0.03)

		if AbilityDamage then
			NetworkingService:FireToClient(playerAttacker, "ShowDamage", AbilityDamage)
		else
			NetworkingService:FireToClient(playerAttacker, "ShowDamage", M1Damage)
		end
	end
end
