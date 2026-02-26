
local sss = game:GetService("ServerScriptService")
local players = game:GetService("Players")

local stateService = require(game.ReplicatedStorage.Modules.StateService)
local DataService = require(sss.Services.DataService)
local CharacterVitalsService = require(sss.Services.CharacterVitalsService)

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
		playerDamageStat = playerStats[weaponData.Type].Final
		playerCriticalDamageStat = playerStats.CriticalDamage.Percent + weaponData.CriticalDamage + 1
		playerCriticalRateStat = (playerStats.CriticalRate.Percent + weaponData.CriticalRate) * 100
	end
	
	if players:GetPlayerFromCharacter(targetHit) then
		targetDefenseStat = DataService:GetTable(players:GetPlayerFromCharacter(targetHit), "Stats").Defense.Final 
	end

	---BlockBreakCounter---
	local status = targetHit:FindFirstChild("Status")
	if not status then return end
	local isBlocking = stateService.checkState(targetHit, "Blocking")

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
