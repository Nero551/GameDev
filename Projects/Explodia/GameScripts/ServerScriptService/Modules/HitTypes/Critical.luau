local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
--Defualt HitType
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local AbilityData = require(ReplicatedStorage.Modules.Data.AbilityData)
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
	local weaponUsed = argumentData.WeaponUsed
	local targetDefenseStat = argumentData.TargetDefenseStat
	local playerDamageStat = argumentData.PlayerDamageStat
	local CriticalDamageStat = argumentData.CriticalDamageStat
	local comboStringNumber = argumentData.ComboStringNumber
	local lastHit = argumentData.LastHit
	local Damage = argumentData.Damage
	local abilityLetter = argumentData.AbilityLetter

	local playerAttacker = Players:GetPlayerFromCharacter(attacker)
	local targetHumanoid: Humanoid = targetHit:WaitForChild("Humanoid")
	local targetHRP = targetHit:WaitForChild("HumanoidRootPart")
	if not targetHumanoid then
		return
	end
	if StateChecker:CheckState(targetHit, "Invulnerable") then
		return
	end
	StateService:AddState(attacker, "In Combat", 20)
	StateService:AddState(targetHit, "In Combat", 20)

	NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit", {
		["Target"] = targetHit,
		["Weapon"] = weaponUsed,
	})

	Damage = FormulaApplier:CriticalDamage(Damage, playerDamageStat, targetDefenseStat, CriticalDamageStat)
	VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		["HealthChange"] = -Damage,
	})
	if abilityLetter then
		local abilityData = AbilityData:GetAbilityData(weaponUsed.Name, abilityLetter)
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Weapons
				:FindFirstChild(weaponUsed.Name).Sounds.Abilities.Hit
				:FindFirstChild(tostring(abilityLetter)),
			["Parent"] = targetHRP,
			["Volume"] = 2
		})
		local hitReactionAnim =
			Animations:GetAnimation(targetHumanoid, "Shared.Character.AbilityHitReactions." .. abilityData.HitReaction)
		hitReactionAnim:Play()
		StateService:AddState(targetHit, "Stunned", hitReactionAnim.Length + 0.3)
	else
		local foundWeaponData = ItemDataBase:GetItemData(weaponUsed:GetAttribute("ID"))
		if foundWeaponData then
			NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
				["Sound"] = ReplicatedStorage.Assets.Weapons
					:FindFirstChild(weaponUsed.Name).Sounds.Hit
					:FindFirstChild(tostring(comboStringNumber)),
				["Parent"] = targetHRP,
			})

			local hitReactionAnim =
				Animations:GetAnimation(targetHumanoid, "Shared.Character.HitReactions." .. tostring(comboStringNumber))
			hitReactionAnim:Play()
			StateService:AddState(targetHit, "Stunned", hitReactionAnim.Length + 0.3)
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

	if playerAttacker then
		NetworkingService:FireToClient(playerAttacker, "Hitstop", 0.06)
		NetworkingService:FireToClient(playerAttacker, "ShowDamage", Damage, true, false)
	end
end
