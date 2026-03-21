local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local StateChecker = ModuleLoader:Load("Shared", "StateChecker")
local DataService = ModuleLoader:Load("Server", "DataService")
local CharacterVitalsService = ModuleLoader:Load("Server", "CharacterVitalsService")
local StatService = ModuleLoader:Load("Server", "StatService")

local HitApplier = {}

function HitApplier:ApplyHit(argumentData)
	
	local targetHit = argumentData.TargetHit
	local weaponData = argumentData.WeaponData
	local player = argumentData.Player
	local hitTypes = argumentData.HitTypes
	local character = argumentData.Character
	local tool = argumentData.Tool
	local abilityData = argumentData.AbilityData
	local npcDamage = argumentData.NPCDamage
	local trueSwingNumber = argumentData.TrueSwingNumber
	local abilityLetter = argumentData.AbilityLetter
	
	local abilityBlockDetoriation
	if abilityData then
		abilityBlockDetoriation = abilityData.BlockDetoriation
	end
	
	local playerDamageStat
	local playerCriticalDamageStat
	local playerCriticalRateStat
	local targetDefenseStat = 0
	if player then
		local playerStats = DataService:GetTable(player,"Stats")
		playerDamageStat = playerStats.MainStats[weaponData.Type].Final
		playerCriticalDamageStat = StatService:GetStat(player, "CriticalDamage").Percent + weaponData.CriticalDamage + 1
		playerCriticalRateStat = (StatService:GetStat(player, "CriticalRate").Percent + weaponData.CriticalRate) * 100
	end
	
	if Players:GetPlayerFromCharacter(targetHit) then
		targetDefenseStat = StatService:GetStat(Players:GetPlayerFromCharacter(targetHit), "Defense").Final 
	end

	---BlockBreakCounter---
	local status = targetHit:FindFirstChild("Status")
	if not status then return end
	local isBlocking = StateChecker:CheckState(targetHit, "Blocking")

	if isBlocking then
		---BlockBreak---
		local blockCounter = CharacterVitalsService:GetVital(targetHit, "BlockCounter")
		
		if blockCounter == 4 then
			CharacterVitalsService:ModifyVital(targetHit, "Combat", "ModifyBlockCounter", {["BlockCounterChange"] = 0})			
			hitTypes["BlockBreak"]({
				["Attacker"] = character,
				["TargetHit"] = targetHit,
				["WeaponUsed"] = tool,
			})

		else
			---Do Blocked HitType----
			CharacterVitalsService:ModifyVital(targetHit, "Combat", "ModifyBlockCounter", {["BlockCounterChange"] = 1 or abilityBlockDetoriation})			
			
			hitTypes["Blocked"]({
				["Attacker"] = character,
				["TargetHit"] = targetHit,
				["AbilityData"] = abilityData,
				["AbilityLetter"] = abilityLetter,
				["WeaponUsed"] = tool,
				["TargetDefenseStat"] = targetDefenseStat,
				["PlayerDamageStat"] = playerDamageStat,
				["NPCDamage"] = npcDamage,
				["Player"] = player
			})
		end
	else
		
		if playerCriticalDamageStat and playerCriticalRateStat and math.random(0,100) <= playerCriticalRateStat then
			
			---BlackFlash HitType---
			if  playerCriticalRateStat >= 150 and math.random(0, 500) <= playerCriticalRateStat - 150  and not abilityData then
				hitTypes["BlackFlash"]({
					["Attacker"] = character,
					["TargetHit"] = targetHit,
					["WeaponUsed"] = tool,
					["ComboStringNumber"] = trueSwingNumber,
					["LastHit"] = (trueSwingNumber == 5 and true or false),
					["PlayerDamageStat"] = playerDamageStat,
					["TargetDefenseStat"] = targetDefenseStat,
					["PlayerCriticalDamageStat"] = playerCriticalDamageStat,
					["Player"] = player,
					["AbilityData"] = abilityData,
					["AbilityLetter"] = abilityLetter,
					["NPCDamage"] = npcDamage, 
					
				})
			else
				---Critical HitType---
				hitTypes["Critical"]({
					["Attacker"] = character,
					["TargetHit"] = targetHit,
					["WeaponUsed"] = tool,
					["ComboStringNumber"] = trueSwingNumber,
					["LastHit"] = (trueSwingNumber == 5 and true or false),
					["PlayerDamageStat"] = playerDamageStat,
					["TargetDefenseStat"] = targetDefenseStat,
					["PlayerCriticalDamageStat"] = playerCriticalDamageStat,
					["Player"] = player,
					["AbilityData"] = abilityData,
					["AbilityLetter"] = abilityLetter,
					["NPCDamage"] = npcDamage,
				})
			end
			
			
		else
			---Status Ailment HitType---
			if weaponData.StatusAilments and math.random(0,100) <= (weaponData.StatusAilments.ProcChance * 100) and not abilityData then
				hitTypes["StatusAilment"]({
					["Attacker"] = character,
					["TargetHit"] = targetHit,
					["WeaponUsed"] = tool,
					["ComboStringNumber"] = trueSwingNumber,
					["LastHit"] = (trueSwingNumber == 5 and true or false),
					["PlayerDamageStat"] = playerDamageStat,
					["TargetDefenseStat"] = targetDefenseStat,
					["Player"] = player,
					["AbilityData"] = abilityData,
					["AbilityLetter"] = abilityLetter,
					["NPCDamage"] = npcDamage,
					["StatusAilments"] = weaponData.StatusAilments.Effects
				})
				
			elseif abilityData and abilityData.StatusAilments and math.random(0,100) <= (abilityData.StatusAilments.ProcChance * 100) then
				
				hitTypes["StatusAilment"]({
					["Attacker"] = character,
					["TargetHit"] = targetHit,
					["WeaponUsed"] = tool,
					["ComboStringNumber"] = trueSwingNumber,
					["LastHit"] = (trueSwingNumber == 5 and true or false),
					["PlayerDamageStat"] = playerDamageStat,
					["TargetDefenseStat"] = targetDefenseStat,
					["Player"] = player,
					["AbilityData"] = abilityData,
					["AbilityLetter"] = abilityLetter,
					["NPCDamage"] = npcDamage,
					["StatusAilments"] = abilityData.StatusAilments.Effects
				})
				
			else
				-----Defualt HitType---
				hitTypes["Default"]({
					["Attacker"] = character,
					["TargetHit"] = targetHit,
					["WeaponUsed"] = tool,
					["ComboStringNumber"] = trueSwingNumber,
					["LastHit"] = (trueSwingNumber == 5 and true or false),
					["PlayerDamageStat"] = playerDamageStat,
					["TargetDefenseStat"] = targetDefenseStat,
					["Player"] = player,
					["AbilityData"] = abilityData,
					["AbilityLetter"] = abilityLetter,
					["NPCDamage"] = npcDamage,
				})
			end
		end
	end
end

return HitApplier
