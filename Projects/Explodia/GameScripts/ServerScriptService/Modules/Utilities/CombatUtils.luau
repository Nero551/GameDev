local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local VitalsService = require(ServerScriptService.Services.Combat.VitalsService)
local StateChecker = require(ReplicatedStorage.Modules.Helpers.StateChecker)
local DataService = require(ServerScriptService.Services.Core.DataService)
local StatService = require(ServerScriptService.Services.Profile.StatService)
local CombatUtils = {}


CombatUtils.HitTypes = nil

function CombatUtils:ApplyKnockback(target, attacker, force)
	local targetHRP = target:WaitForChild("HumanoidRootPart")
	local knockbackAttachment = targetHRP:FindFirstChild("VelocityAttachment")
	if not knockbackAttachment then
		knockbackAttachment = Instance.new("Attachment")
		knockbackAttachment.Name = "KnockbackVelocityAttachment"
		knockbackAttachment.Parent = targetHRP
	end

	local knockbackVelocity = targetHRP:FindFirstChild("KnockBackLinVelocity")
	if not knockbackVelocity then
		knockbackVelocity = Instance.new("LinearVelocity")
		knockbackVelocity.Attachment0 = knockbackAttachment
		knockbackVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
		knockbackVelocity.MaxForce = math.huge
		knockbackVelocity.VectorVelocity = attacker.HumanoidRootPart.CFrame.LookVector * force
		knockbackVelocity.Parent = targetHRP
		knockbackAttachment.Name = "KnockBackLinVelocity"
	end

	Debris:AddItem(knockbackAttachment, 0.13)
	Debris:AddItem(knockbackVelocity, 0.13)
end

function CombatUtils:ApplyPull(target, attacker, force)
	local targetHRP = target:WaitForChild("HumanoidRootPart")
	local attackerHRP = attacker:WaitForChild("HumanoidRootPart")

	local pullAttachment = targetHRP:FindFirstChild("VelocityAttachment")
	if not pullAttachment then
		pullAttachment = Instance.new("Attachment")
		pullAttachment.Name = "PullVelocityAttachment"
		pullAttachment.Parent = attackerHRP
	end

	local pullVelocity = targetHRP:FindFirstChild("PullLinVelocity")
	if not pullVelocity then
		pullVelocity = Instance.new("LinearVelocity")
		pullVelocity.Attachment0 = pullAttachment
		pullVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
		pullVelocity.MaxForce = math.huge
		pullVelocity.VectorVelocity = attackerHRP.CFrame.LookVector * force
		pullVelocity.Parent = attackerHRP
		pullVelocity.Name = "PullLinVelocity"
	end

	Debris:AddItem(pullAttachment, 0.13)
	Debris:AddItem(pullVelocity, 0.13)
end

function CombatUtils:ApplyHit(argumentData)
    if not CombatUtils.HitTypes then
        CombatUtils.HitTypes = {}
		for _, module in game.ServerScriptService.Modules.HitTypes:GetChildren() do
			if module:IsA("ModuleScript") then
				CombatUtils.HitTypes[module.Name] = require(module)
			end
		end
    end
	local targetHit = argumentData.TargetHit
	local attacker = argumentData.Attacker
	local tool = argumentData.Tool
	local trueSwingNumber = argumentData.TrueSwingNumber

	local abilityData = argumentData.AbilityData
	local abilityLetter = argumentData.AbilityLetter

	local playerDamageStat
	local playerCriticalDamageStat
	local playerCriticalRateStat
	local targetDefenseStat = 0

    local weaponData = ItemDataBase:GetItemData(tool:GetAttribute("ID"))
	local playerAttacker = Players:GetPlayerFromCharacter(attacker)
	local playerTarget = Players:GetPlayerFromCharacter(targetHit)

	if playerAttacker then
		local playerStats = DataService:GetTable(playerAttacker, "Stats")
		playerDamageStat = playerStats.MainStats[weaponData.Type].Final
		playerCriticalDamageStat = StatService:GetStat(playerAttacker, "CriticalDamage").Percent
			+ weaponData.CriticalDamage
			+ 1
		playerCriticalRateStat = (StatService:GetStat(playerAttacker, "CriticalRate").Percent + weaponData.CriticalRate)
			* 100
	end

	if playerTarget then
		targetDefenseStat = StatService:GetStat(playerTarget, "Defense").Final
	end

	---BlockBreakCounter---
	local status = targetHit:FindFirstChild("Status")
	if not status then
		return
	end

    CombatUtils:AddKillerHit(playerAttacker, targetHit)

	local isBlocking = StateChecker:CheckState(targetHit, "Blocking")
	if isBlocking then
		---BlockBreak---
		local blockCounter = VitalsService:GetVital(targetHit, "BlockCounter")

		if blockCounter == 4 then
			VitalsService:ModifyVital(
				targetHit,
				"Combat",
				"ModifyBlockCounter",
				{ ["BlockCounterChange"] = 0 }
			)
			CombatUtils.HitTypes["BlockBreak"]({
				["Attacker"] = attacker,
				["TargetHit"] = targetHit,
				["WeaponUsed"] = tool,
			})
		else
			---Do Blocked HitType----
			VitalsService:ModifyVital(
				targetHit,
				"Combat",
				"ModifyBlockCounter",
				{ ["BlockCounterChange"] = abilityData.BlockDetoriation or 1 }
			)

			CombatUtils.HitTypes["Blocked"]({
				["Attacker"] = attacker,
				["TargetHit"] = targetHit,
				["AbilityData"] = abilityData,
				["AbilityLetter"] = abilityLetter,
				["WeaponUsed"] = tool,
				["TargetDefenseStat"] = targetDefenseStat,
				["PlayerDamageStat"] = playerDamageStat,
			})
		end
	else
		if playerCriticalDamageStat and playerCriticalRateStat and math.random(0, 100) <= playerCriticalRateStat then
			---BlackFlash HitType---
			if
				playerCriticalRateStat >= 150
				and math.random(0, 500) <= playerCriticalRateStat - 150
				and not abilityData
			then
				CombatUtils.HitTypes["BlackFlash"]({
					["Attacker"] = attacker,
					["TargetHit"] = targetHit,
					["WeaponUsed"] = tool,
					["ComboStringNumber"] = trueSwingNumber,
					["LastHit"] = (trueSwingNumber == 5 and true or false),
					["PlayerDamageStat"] = playerDamageStat,
					["TargetDefenseStat"] = targetDefenseStat,
					["PlayerCriticalDamageStat"] = playerCriticalDamageStat,
					["AbilityData"] = abilityData,
					["AbilityLetter"] = abilityLetter,
				})
			else
				---Critical HitType---
				CombatUtils.HitTypes["Critical"]({
					["Attacker"] = attacker,
					["TargetHit"] = targetHit,
					["WeaponUsed"] = tool,
					["ComboStringNumber"] = trueSwingNumber,
					["LastHit"] = (trueSwingNumber == 5 and true or false),
					["PlayerDamageStat"] = playerDamageStat,
					["TargetDefenseStat"] = targetDefenseStat,
					["PlayerCriticalDamageStat"] = playerCriticalDamageStat,
					["AbilityData"] = abilityData,
					["AbilityLetter"] = abilityLetter,
				})
			end
		else
			---Status Ailment HitType---
			if (abilityData and abilityData.StatusAilments) or weaponData.StatusAilments
					and math.random(0, 100) <= (((abilityData and abilityData.StatusAilments.ProcChance) or weaponData.StatusAilments.ProcChance) * 100)
					and not abilityData
			then
				CombatUtils.HitTypes["StatusAilment"]({
					["Attacker"] = attacker,
					["TargetHit"] = targetHit,
					["WeaponUsed"] = tool,
					["ComboStringNumber"] = trueSwingNumber,
					["LastHit"] = (trueSwingNumber == 5 and true or false),
					["PlayerDamageStat"] = playerDamageStat,
					["TargetDefenseStat"] = targetDefenseStat,
					["AbilityData"] = abilityData,
					["AbilityLetter"] = abilityLetter,
					["StatusAilments"] = (abilityData and abilityData.StatusAilments.Effects)
						or weaponData.StatusAilments.Effects,
				})
			else
				-----Defualt HitType---
				CombatUtils.HitTypes["Default"]({
					["Attacker"] = attacker,
					["TargetHit"] = targetHit,
					["WeaponUsed"] = tool,
					["ComboStringNumber"] = trueSwingNumber,
					["LastHit"] = (trueSwingNumber == 5 and true or false),
					["PlayerDamageStat"] = playerDamageStat,
					["TargetDefenseStat"] = targetDefenseStat,
					["AbilityData"] = abilityData,
					["AbilityLetter"] = abilityLetter,
				})
			end
		end
	end
end

function CombatUtils:AddKillerHit(playerAttacker,targetHit)
	local killerHit = targetHit:WaitForChild("Humanoid"):FindFirstChild("KillerHit")
	if killerHit and killerHit.Value == playerAttacker then
		killerHit:Destroy()
	end
	killerHit = Instance.new("ObjectValue")
	killerHit.Parent = targetHit:WaitForChild("Humanoid")
	killerHit.Value = playerAttacker
	killerHit.Name = "KillerHit"
	Debris:AddItem(killerHit, 30)
end

return CombatUtils
