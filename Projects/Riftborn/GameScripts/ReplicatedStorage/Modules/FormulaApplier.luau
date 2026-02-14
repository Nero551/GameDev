
local FormulaApplier = {}

function FormulaApplier:DefaultHitFormula(data , npcDamage, targetDefenseStat, playerDamageStat)
	
	local defaultDamage = math.max((npcDamage or data.Damage) * (100/ (100 + targetDefenseStat)),
		math.floor(
			(1+ data.Damage / 100) * (npcDamage or playerDamageStat)) * ( 100 / ( 100 + targetDefenseStat )))
	
	return defaultDamage
end

function FormulaApplier:BlockedHitFormula(data, npcDamage, targetDefenseStat, playerDamageStat)
	
	local blockedDamage = math.max((npcDamage or data.Damage) * (100/ (100 + targetDefenseStat)),
		math.floor(
			(1+ data.Damage / 100) * (npcDamage or playerDamageStat)) * ( 100 / ( 100 + targetDefenseStat ))*0.1)
	
	return blockedDamage
end

function FormulaApplier:CriticalHitFormula(data, targetDefenseStat, playerCriticalDamageStat, playerDamageStat)
	local criticalDamage =  math.max(data.Damage * (100/ (100 + targetDefenseStat)),
		math.floor((
			(1+ data.Damage / 100) * playerDamageStat) *
				( 100 / ( 100 + targetDefenseStat )))) * playerCriticalDamageStat
	return criticalDamage
end

function FormulaApplier:BlackFlashHitFormula(data, targetDefenseStat, playerCriticalDamageStat, playerDamageStat)
	local blackFlashDamage = math.max(data.Damage * (100/ (100 + targetDefenseStat)),
		math.floor((
			(1+ data.Damage / 100) * playerDamageStat) *
				( 100 / ( 100 + targetDefenseStat )))) * playerCriticalDamageStat * 2
	return blackFlashDamage
end

function FormulaApplier:M1Damage(argumentData)

	local npcDamage = argumentData.NPCDamage
	local blocked = argumentData.Blocked
	local playerDamageStat  = argumentData.PlayerDamageStat
	local targetDefenseStat = argumentData.TargetDefenseStat
	local playerCriticalDamageStat = argumentData.PlayerCriticalDamageStat	
	local foundWeaponData = argumentData.FoundWeaponData
	local blackFlash = argumentData.BlackFlash

	local M1Damage
	
	---If target Blocking---
	if blocked then
		M1Damage = FormulaApplier:BlockedHitFormula(foundWeaponData, npcDamage, targetDefenseStat, playerDamageStat)

	elseif playerCriticalDamageStat then

		---If BlackFlash---
		if blackFlash == true then
			M1Damage = FormulaApplier:BlackFlashHitFormula(foundWeaponData, targetDefenseStat,
				playerCriticalDamageStat, playerDamageStat)
		else

			---If Crit---	
			M1Damage = FormulaApplier:CriticalHitFormula(foundWeaponData, targetDefenseStat,
				playerCriticalDamageStat, playerDamageStat)
		end
	else
		---Default---
		M1Damage = FormulaApplier:DefaultHitFormula(foundWeaponData, npcDamage, targetDefenseStat, playerDamageStat)
	end	
	
	return M1Damage
end


function FormulaApplier:AbilityDamage(argumentData)
	
	local npcDamage = argumentData.NPCDamage
	local blocked = argumentData.Blocked
	local abilityData = argumentData.AbilityData
	local targetDefenseStat = argumentData.TargetDefenseStat
	local playerDamageStat  = argumentData.PlayerDamageStat
	local playerCriticalDamageStat = argumentData.PlayerCriticalDamageStat
	local blackFlash = argumentData.BlackFlash
	
	local AbilityDamage
	
	if blocked then
		---Blocked---
		AbilityDamage = FormulaApplier:BlockedHitFormula(abilityData, npcDamage, targetDefenseStat, playerDamageStat)

	elseif playerCriticalDamageStat then
		if blackFlash then
			---BlackFlash---
			AbilityDamage = FormulaApplier:BlackFlashHitFormula(abilityData, targetDefenseStat,
				playerCriticalDamageStat, playerDamageStat)
			warn("BlackFlash")
		else
			---Critical---
			AbilityDamage = FormulaApplier:CriticalHitFormula(abilityData, targetDefenseStat,
				playerCriticalDamageStat, playerDamageStat)
		end

	else
		---Default---
		AbilityDamage = FormulaApplier:DefaultHitFormula(abilityData, npcDamage, targetDefenseStat, playerDamageStat)
	end
	
	return AbilityDamage
end



return FormulaApplier
