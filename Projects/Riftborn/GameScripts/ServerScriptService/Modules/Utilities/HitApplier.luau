local sss = game:GetService("ServerScriptService")
local players = game:GetService("Players")

local stateService = require(game.ReplicatedStorage.Modules.StateService)
local DataService = require(sss.Services.DataService)

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
	local blockCounter = status:WaitForChild("BlockCounter")

	local isBlocking = stateService.checkState(targetHit, "Blocking")

	if isBlocking then
		---BlockBreak---
		if blockCounter.Value == 4 then
			blockCounter.Value = 0
			blockCounter.Value = math.clamp(blockCounter.Value, 0 , 4)
			
			hitTypes["BlockBreak"]({
				["Attacker"] = character,
				["TargetHit"] = targetHit,
				["WeaponUsed"] = tool,
			})

		else
			---Do Blocked HitType----
			blockCounter.Value += 1
			blockCounter.Value = math.clamp(blockCounter.Value, 0 , 4)
			
			hitTypes["Blocked"]({
				["Attacker"] = character,
				["TargetHit"] = targetHit,
				["AbilityData"] = abilityData,
				["WeaponUsed"] = tool,
				["TargetDefenseStat"] = targetDefenseStat,
				["PlayerDamageStat"] = playerDamageStat,
				["NPCDamage"] = npcDamage,
				["Player"] = player
			})
		end
	else
		
		---Critical HitType---
		if playerCriticalDamageStat and playerCriticalRateStat and math.random(0,100) <= playerCriticalRateStat then

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
				["NPCDamage"] = npcDamage,
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
				["NPCDamage"] = npcDamage,
			})
		end
	end
end

return HitApplier
