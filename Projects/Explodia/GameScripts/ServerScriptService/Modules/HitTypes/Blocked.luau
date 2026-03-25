local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
--Defualt HitType
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

	Damage = FormulaApplier:BlockedDamage(Damage, playerDamageStat, targetDefenseStat)
	VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		["HealthChange"] = -Damage,
	})
	if abilityLetter then
		NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Shared.Sounds.AbilityBlock,
			["Parent"] = targetHit.HumanoidRootPart,
		})
	else
		local foundWeaponData = ItemDataBase:GetItemData(weaponUsed:GetAttribute("ID"))
		if foundWeaponData then
			local randomNumber = math.random(1, 4)
			NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "Sound", {
				["Sound"] = ReplicatedStorage.Assets.Weapons
					:FindFirstChild(weaponUsed.Name).Sounds.Blocked
					:FindFirstChild(tostring(randomNumber)),
				["Parent"] = targetHit.HumanoidRootPart,
			})
		end
	end

	NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "BlockedHit", {
		["Target"] = targetHit,
		["Weapon"] = weaponUsed,
		["BlockCounter"] = VitalsService:GetVital(targetHit, "BlockCounter"),
	})

	task.spawn(function()
		local randomShrug = math.random(1, 2)
		Animations:GetAnimation(targetHumanoid, "Shared.Character.BlockReactions.BlockShrug" .. tostring(randomShrug))
			:Play()
	end)

	if playerAttacker then
		NetworkingService:FireToClient(playerAttacker, "ShowDamage", Damage,false,true)
	end
end
