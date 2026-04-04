local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StatusEffectsService = require(script.Parent.StatusEffectsService)
local CombatUtils = require(ServerScriptService.Modules.Utilities.CombatUtils)
local NPCService = require(ServerScriptService.Services.NPC.NPCService)
local StatService = require(ServerScriptService.Services.Profile.StatService)
local MobData = require(ReplicatedStorage.Modules.Data.MobData)
local StatusEffectsData = require(ReplicatedStorage.Modules.Data.StatusEffectsData)
local StateChecker = require(ReplicatedStorage.Modules.Helpers.StateChecker)
local DamageService = require(script.Parent.DamageService)
local HitReactionsService = require(script.Parent.HitReactionsService)
local VitalsService = require(script.Parent.VitalsService)
local HitService = {}

function HitService:Apply(attacker, data, tool, hitbox, trueSwingNumber)
	local baseDamage = 0

	local playerAttacker = Players:GetPlayerFromCharacter(attacker)
	local totalScaling = 0
	local critDamage = data.CriticalDamage or 0
	local critChance = data.CriticalChance or 0
	local targetDefense = 0
	if playerAttacker then
		for statType, value in pairs(data.Scaling) do
			local stat = StatService:GetStat(playerAttacker, statType)
			if stat then
				totalScaling += stat.Final * value
			end
		end

		critDamage += StatService:GetStat(playerAttacker, "CriticalDamage").Final
		critChance += StatService:GetStat(playerAttacker, "CriticalChance").Final

		baseDamage = math.random(data.MinDamage, data.MaxDamage)
	end

	local mobData = MobData.Mobs[attacker.Name]
	if mobData then
		local npcData = NPCService.SpawnedNPCS[mobData.Type][attacker]
		if npcData then
			baseDamage = math.random(npcData.MinDamage, npcData.MaxDamage)
		end
	end

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { attacker, workspace.World.Hitboxes }

	local Targets = {}
	for _, part in workspace:GetPartsInPart(hitbox, params) do
		local target = part:FindFirstAncestorOfClass("Model")
		local humanoid = target and target:FindFirstChild("Humanoid")
		if target and humanoid and not Targets[target] then
			Targets[target] = true
		end
	end

	for targetHit, _ in pairs(Targets) do
		if StateChecker:CheckState(targetHit, "Invulnerable") then
			continue
		end
		for Hit = 1, (data.Hits or 1), 1 do
			local playerTarget = Players:GetPlayerFromCharacter(targetHit)
			if playerTarget then
				targetDefense = StatService:GetStat(playerTarget, "Defense").Final
			end
			CombatUtils:AddKillerHit(attacker, targetHit)
			local damage = 0
			if StateChecker:CheckState(targetHit, "Blocking") then
				---BlockBreak---
				local blockCounter = VitalsService:GetVital(targetHit, "BlockCounter")
				if blockCounter == 4 then
					VitalsService:ModifyVital(targetHit, "Combat", "ModifyBlockCounter", { ["BlockCounterChange"] = 0 })
					HitReactionsService:BlockBreak(attacker, targetHit, data)
					DamageService:BlockBreakDamage()
				else
					---Do Blocked HitType----
					VitalsService:ModifyVital(
						targetHit,
						"Combat",
						"ModifyBlockCounter",
						{ ["BlockCounterChange"] = data.BlockDetoriation or 1 }
					)
					HitReactionsService:Blocked(attacker, targetHit, data)
					damage = DamageService:BlockedDamage(attacker, targetHit, baseDamage, totalScaling, targetDefense)
				end
			else
				if critChance and critDamage and math.random(0, 1) <= critChance then
					---BlackFlash HitType---
					if critChance >= 1.5 and math.random(0, 5) <= critChance - 1.5 and not data.TechniqueName then
						HitReactionsService:BlackFlash(attacker, targetHit, data, trueSwingNumber)
						damage = DamageService:BlackFlashDamage(
							attacker,
							targetHit,
							baseDamage,
							totalScaling,
							targetDefense,
							critDamage
						)
					else
						---Critical HitType---
						HitReactionsService:Critical(attacker, targetHit, data, trueSwingNumber)
						damage = DamageService:CriticalDamage(
							attacker,
							targetHit,
							baseDamage,
							totalScaling,
							targetDefense,
							critDamage
						)
					end
				else
					---Status Effect HitType---
					if data.StatusEffects and math.random(0, 100) <= data.StatusEffects.ProcChance * 100 then
						damage =
							DamageService:DefaultDamage(attacker, targetHit, baseDamage, totalScaling, targetDefense)
						local randomStatusEffect = math.random(1, #data.StatusEffects.Effects)
						local statusEffectName = data.StatusEffects.Effects[randomStatusEffect]
						local statusEffectData = StatusEffectsData.StatusEffects[statusEffectName]
						if not statusEffectData then
							return
						end
						HitReactionsService:StatusEffect(attacker, targetHit, data, trueSwingNumber, randomStatusEffect)
						StatusEffectsService[statusEffectName](
							StatusEffectsService,
							attacker,
							targetHit,
							statusEffectName,
							damage,
							targetDefense
						)
					else
						-----Defualt HitType---
						HitReactionsService:Default(attacker, targetHit, data, trueSwingNumber)
						damage =
							DamageService:DefaultDamage(attacker, targetHit, baseDamage, totalScaling, targetDefense)
					end
				end
			end
			if data.TimeBtwnHits then
				task.wait(data.TimeBtwnHits)
			end
		end
	end
end

return HitService
