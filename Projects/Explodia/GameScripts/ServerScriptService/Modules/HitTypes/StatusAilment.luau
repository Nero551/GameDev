local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
--StatusAilment HitType
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FormulaApplier = require(game.ReplicatedStorage.Modules.Helpers.FormulaApplier)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local ServerScriptService = game:GetService("ServerScriptService")
local CombatUtils = require(ServerScriptService.Modules.Utilities.CombatUtils)
local StateService = require(game.ServerScriptService.Services.Core.StateService)
local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)
local StatusAilmentsData = require(game.ReplicatedStorage.Modules.Data.StatusAilmentsData)

local AilmentService = require(game.ServerScriptService.Services.Combat.AilmentService)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

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
	local ailmentName
	local ailmentData

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

	if abilityData then
		AbilityDamage = FormulaApplier:AbilityDamage({
			["AbilityData"] = abilityData,
			["TargetDefenseStat"] = targetDefenseStat,
			["PlayerDamageStat"] = playerDamageStat,
			["NPCDamage"] = npcDamage,
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
				["NPCDamage"] = npcDamage,
				["PlayerDamageStat"] = playerDamageStat,
				["TargetDefenseStat"] = targetDefenseStat,
				["FoundWeaponData"] = foundWeaponData,
			})

			VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
				["HealthChange"] = -M1Damage,
			})

			
			NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
				["Sound"] = ReplicatedStorage.Assets.Weapons:FindFirstChild(weaponUsed.Name).Sounds.Hit:FindFirstChild(tostring(comboStringNumber)),
				["Parent"] = targetHRP,
			})

			local hitReactionAnim =
				Animations:GetAnimation(targetHumanoid, "Shared.Character.HitReactions." .. tostring(comboStringNumber))
			hitReactionAnim:Play()
			StateService:AddState(targetHit, "Stunned", hitReactionAnim.Length + 0.1)
		end

		------Control KnockBack------
		if lastHit then
			------EndLag Setup------
			StateService:AddState(attacker, "NoMove", 0.5)
			StateService:AddState(attacker, "NoPunch", 1)

			CombatUtils:ApplyKnockback(targetHit, attacker, 90)
		else
			CombatUtils:ApplyKnockback(targetHit, attacker, 11)
			CombatUtils:ApplyPull(targetHit, attacker, 11)
		end
	end

	if statusAilments then
		local randomAilment = math.random(1, #statusAilments)
		ailmentName = statusAilments[randomAilment]
		ailmentData = StatusAilmentsData.Ailments[ailmentName]
		if not ailmentData then
			return
		end

		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "AilmentHit", {
			["Target"] = targetHit,
			["Ailment"] = ailmentName,
			["Weapon"] = weaponUsed
		})

		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
			["Parent"] = targetHRP,
			["Sound"] = ReplicatedStorage.Assets.Shared.Sounds.AilmentSounds:FindFirstChild(ailmentName),
		})

		AilmentService[ailmentName](AilmentService, attacker, targetHit, ailmentName, M1Damage or AbilityDamage)
	end

	if player then
		NetworkingService:FireToClient(player, "Hitstop", 0.03)

		if AbilityDamage then
			NetworkingService:FireToClient(player, "ShowDamage", AbilityDamage, false, false, false, ailmentName)
		else
			NetworkingService:FireToClient(player, "ShowDamage", M1Damage, false, false, false, ailmentName)
		end
	end
end
