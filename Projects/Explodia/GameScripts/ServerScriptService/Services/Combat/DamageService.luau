local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local StatusEffectsData = require(ReplicatedStorage.Modules.Data.StatusEffectsData)
local VitalsService = require(script.Parent.VitalsService)
local DamageService = {}

function DamageService:DefaultDamage(attacker, targetHit, baseDamage, totalScaling, targetDefense)
	local targetHumanoid = targetHit:FindFirstChild("Humanoid")
	if not targetHumanoid then
		return
	end

	local damage = math.floor((baseDamage + baseDamage * (totalScaling ^ 1.1)) * (100 / (100 + targetDefense)))

	VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		["HealthChange"] = -damage,
	})

	if Players:GetPlayerFromCharacter(attacker) then
		NetworkingService:FireToClient(Players:GetPlayerFromCharacter(attacker), "ShowDamage", damage)
	end
	return damage
end

function DamageService:CriticalDamage(attacker, targetHit, baseDamage, totalScaling, targetDefense, critDamage)
	local damage =
		math.floor((baseDamage + baseDamage * (totalScaling ^ 1.1)) * (100 / (100 + targetDefense)) * critDamage)

	VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		["HealthChange"] = -damage,
	})
	if Players:GetPlayerFromCharacter(attacker) then
		NetworkingService:FireToClient(Players:GetPlayerFromCharacter(attacker), "ShowDamage", damage, true)
	end
	return damage
end

function DamageService:BlockedDamage(attacker, targetHit, baseDamage, totalScaling, targetDefense)
	local damage = math.floor((baseDamage + baseDamage * (totalScaling ^ 1.1)) * (100 / (100 + targetDefense)) * 0.2)

	VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		["HealthChange"] = -damage,
	})
	if Players:GetPlayerFromCharacter(attacker) then
		NetworkingService:FireToClient(Players:GetPlayerFromCharacter(attacker), "ShowDamage", damage, false, true)
	end
	return damage
end

function DamageService:BlackFlashDamage(attacker, targetHit, baseDamage, totalScaling, targetDefense, critDamage)
	local damage =
		math.floor((baseDamage + baseDamage * (totalScaling ^ 1.1)) * (100 / (100 + targetDefense)) * critDamage * 2)

	VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		["HealthChange"] = -damage,
	})
	if Players:GetPlayerFromCharacter(attacker) then
		NetworkingService:FireToClient(
			Players:GetPlayerFromCharacter(attacker),
			"ShowDamage",
			damage,
			false,
			false,
			true
		)
	end
	return damage
end

function DamageService:BurnDamage(attacker, targetHit, baseDamage, targetDefense)
	VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		["HealthChange"] = baseDamage * StatusEffectsData.StatusEffects.Burn.DamagePercent,
	})

	if Players:GetPlayerFromCharacter(attacker) then
		NetworkingService:FireToClient(
			Players:GetPlayerFromCharacter(attacker),
			"ShowDamage",
			baseDamage * StatusEffectsData.StatusEffects.Burn.DamagePercent,
			false,
			false,
			false,
			"Burn"
		)
	end
end

function DamageService:BleedDamage(attacker, targetHit, baseDamage, targetDefense)
	VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		["HealthChange"] = baseDamage * StatusEffectsData.StatusEffects.Bleed.DamagePercent,
	})

	if Players:GetPlayerFromCharacter(attacker) then
		NetworkingService:FireToClient(
			Players:GetPlayerFromCharacter(attacker),
			"ShowDamage",
			baseDamage * StatusEffectsData.StatusEffects.Bleed.DamagePercent,
			false,
			false,
			false,
			"Bleed"
		)
	end
end

function DamageService:FreezeDamage(attacker, targetHit, baseDamage, targetDefense)
	VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		["HealthChange"] = baseDamage * StatusEffectsData.StatusEffects.Freeze.DamagePercent,
	})

	if Players:GetPlayerFromCharacter(attacker) then
		NetworkingService:FireToClient(
			Players:GetPlayerFromCharacter(attacker),
			"ShowDamage",
			baseDamage * StatusEffectsData.StatusEffects.Freeze.DamagePercent,
			false,
			false,
			false,
			"Freeze"
		)
	end
end

return DamageService
