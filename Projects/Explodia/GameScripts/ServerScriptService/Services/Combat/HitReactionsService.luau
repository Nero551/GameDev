local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local VitalsService = require(script.Parent.VitalsService)
local CombatUtils = require(ServerScriptService.Modules.Utilities.CombatUtils)
local Animations = require(ReplicatedStorage.Modules.Core.Animations)
local StateService = require(ServerScriptService.Services.Core.StateService)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local StatusEffectsData = require(ReplicatedStorage.Modules.Data.StatusEffectsData)
local StateChecker = require(ReplicatedStorage.Modules.Helpers.StateChecker)
local HitReactionsService = {}

function HitReactionsService:Default(attacker, targetHit, data, trueSwingNumber)
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

	local hitReactionAnim = Animations:GetAnimation(
		targetHumanoid,
		"Combat.HitReactions." .. tostring(trueSwingNumber or (math.random(1, 5)))
	)
	hitReactionAnim:Play()
	StateService:AddState(targetHit, "Stunned", hitReactionAnim.Length + 0.1)

	if data.TechniqueName then
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit", {
			["Target"] = targetHit,
			["Technique"] = data.TechniqueName,
		})
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Techniques[data.TechniqueName].Hit,
			["Parent"] = targetHRP,
		})
	else
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit", {
			["Target"] = targetHit,
			["Weapon"] = data.Name,
		})
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Weapons
				:FindFirstChild(data.Name).Sounds.Hit
				:FindFirstChild(tostring(trueSwingNumber)),
			["Parent"] = targetHRP,
		})

		------Control KnockBack------
		if trueSwingNumber == 5 then
			StateService:AddState(attacker, "NoMove", 0.5)
			StateService:AddState(attacker, "NoPunch", 1)
			CombatUtils:ApplyKnockback(targetHit, attacker, 90)
		else
			CombatUtils:ApplyKnockback(targetHit, attacker, 11)
			CombatUtils:ApplyPull(targetHit, attacker, 11)
		end
	end

	if playerAttacker then
		NetworkingService:FireToClient(playerAttacker, "Hitstop", 0.03)
	end
end

function HitReactionsService:Blocked(attacker, targetHit, data)
	local targetHumanoid: Humanoid = targetHit:WaitForChild("Humanoid")
	if not targetHumanoid then
		return
	end
	if StateChecker:CheckState(targetHit, "Invulnerable") then
		return
	end
	StateService:AddState(attacker, "In Combat", 20)
	StateService:AddState(targetHit, "In Combat", 20)

	if data then
		NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Combat.Block.AbilityBlock,
			["Parent"] = targetHit.HumanoidRootPart,
		})
	else
		local randomNumber = math.random(1, 4)
		NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Weapons
				:FindFirstChild(data.Name).Sounds.Blocked
				:FindFirstChild(tostring(randomNumber)),
			["Parent"] = targetHit.HumanoidRootPart,
		})
	end

	NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "BlockedHit", {
		["Target"] = targetHit,
		["BlockCounter"] = VitalsService:GetVital(targetHit, "BlockCounter"),
	})

	task.spawn(function()
		local randomShrug = math.random(1, 2)
		Animations:GetAnimation(targetHumanoid, "Combat.Block.BlockReactions.BlockShrug" .. tostring(randomShrug))
			:Play()
	end)
end

function HitReactionsService:BlockBreak(attacker, targetHit, data)
	if StateChecker:CheckState(targetHit, "Invulnerable") then
		return
	end

	local targetHumanoid: Humanoid = targetHit:FindFirstChild("Humanoid")
	if not targetHumanoid then
		return
	end

	StateService:AddState(targetHit, "Stunned", 1.5)
	StateService:AddState(targetHit, "BlockBroken", 1.5)
	StateService:AddState(targetHit, "NoBlock", 5)

	StateService:AddState(attacker, "In Combat", 20)
	StateService:AddState(targetHit, "In Combat", 20)

	NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "Sound", {
		["Sound"] = ReplicatedStorage.Assets.Combat.BlockBreak.Sound,
		["Parent"] = targetHit.HumanoidRootPart,
	})

	NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "BlockBreakHit", {
		["Target"] = targetHit,
	})
	Animations:GetAnimation(targetHumanoid, "Combat.BlockBreak.Animation"):Play()
end

function HitReactionsService:Critical(attacker, targetHit, data, trueSwingNumber)
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

	local hitReactionAnim = Animations:GetAnimation(
		targetHumanoid,
		"Combat.HitReactions." .. tostring(trueSwingNumber or (math.random(1, 5)))
	)
	hitReactionAnim:Play()
	StateService:AddState(targetHit, "Stunned", hitReactionAnim.Length + 0.1)

	if data.TechniqueName then
		--TODO ADD Critical HIT EFFECT---
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit", {
			["Target"] = targetHit,
			["Technique"] = data.TechniqueName,
		})
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Techniques[data.TechniqueName].Hit,
			["Parent"] = targetHRP,
			["Volume"] = 2,
		})
	else
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit", {
			["Target"] = targetHit,
			["Weapon"] = data.Name,
		})
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Weapons
				:FindFirstChild(data.Name).Sounds.Hit
				:FindFirstChild(tostring(trueSwingNumber)),
			["Parent"] = targetHRP,
			["Volume"] = 2,
		})

		------Control KnockBack------
		if trueSwingNumber == 5 then
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
	end
end

function HitReactionsService:BlackFlash(attacker, targetHit, data, trueSwingNumber)
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

	NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "BlackFlashHit", {
		["Target"] = targetHit,
	})

	local hitReactionAnim = Animations:GetAnimation(
		targetHumanoid,
		"Combat.HitReactions." .. tostring(trueSwingNumber or (math.random(1, 5)))
	)
	hitReactionAnim:Play()
	StateService:AddState(targetHit, "Stunned", hitReactionAnim.Length + 0.1)

	NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
		["Parent"] = targetHumanoid,
		["SoundName"] = ReplicatedStorage.Assets.Combat.BlackFlash.Sound,
	})

	if data.TechniqueName then
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit", {
			["Target"] = targetHit,
			["Technique"] = data.TechniqueName,
		})
	else
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit", {
			["Target"] = targetHit,
			["Weapon"] = data.Name,
		})

		------Control KnockBack------
		if trueSwingNumber == 5 then
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
	end
end

function HitReactionsService:StatusEffect(attacker, targetHit, data, trueSwingNumber, randomStatusEffect)
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

	local hitReactionAnim = Animations:GetAnimation(
		targetHumanoid,
		"Combat.HitReactions." .. tostring(trueSwingNumber or (math.random(1, 5)))
	)
	hitReactionAnim:Play()
	StateService:AddState(targetHit, "Stunned", hitReactionAnim.Length + 0.1)

	if data.TechniqueName then
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit", {
			["Target"] = targetHit,
			["Technique"] = data.TechniqueName,
		})
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Techniques[data.TechniqueName].Hit,
			["Parent"] = targetHRP,
		})
	else
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit", {
			["Target"] = targetHit,
			["Weapon"] = data.Name,
		})
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Weapons
				:FindFirstChild(data.Name).Sounds.Hit
				:FindFirstChild(tostring(trueSwingNumber)),
			["Parent"] = targetHRP,
		})

		------Control KnockBack------
		if trueSwingNumber == 5 then
			StateService:AddState(attacker, "NoMove", 0.5)
			StateService:AddState(attacker, "NoPunch", 1)
			CombatUtils:ApplyKnockback(targetHit, attacker, 90)
		else
			CombatUtils:ApplyKnockback(targetHit, attacker, 11)
			CombatUtils:ApplyPull(targetHit, attacker, 11)
		end
	end

	if data.StatusEffects then
		local statusEffectName = data.StatusEffects.Effects[randomStatusEffect]
		local statusEffectData = StatusEffectsData.StatusEffects[statusEffectName]
		if not statusEffectData then
			return
		end

		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "StatusEffectHit", {
			["Target"] = targetHit,
			["StatusEffect"] = statusEffectName,
		})

		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound", {
			["Parent"] = targetHRP,
			["Sound"] = ReplicatedStorage.Assets.Combat.StatusEffects.StatusEffectSounds[statusEffectName],
		})
	end

	if playerAttacker then
		NetworkingService:FireToClient(playerAttacker, "Hitstop", 0.03)
	end
end

return HitReactionsService
