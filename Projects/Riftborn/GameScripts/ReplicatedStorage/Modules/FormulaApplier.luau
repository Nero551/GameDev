
local FormulaApplier = {}

function FormulaApplier:M1Damage(argumentData)

	local npcDamage = argumentData.NPCDamage
	local blocked = argumentData.Blocked
	local playerDamageStat  = argumentData.PlayerDamageStat
	local targetDefenseStat = argumentData.TargetDefenseStat
	local playerCriticalDamageStat = argumentData.PlayerCriticalDamageStat	
	local foundWeaponData = argumentData.FoundWeaponData

	local M1Damage
	
	---If NPC---
	if npcDamage then
		
		---If target Blocking---
		if blocked then

			M1Damage = math.max(npcDamage * (100/ (100 + targetDefenseStat)),
				math.floor(
					(1+ foundWeaponData.Damage / 100) * npcDamage) * ( 100 / ( 100 + targetDefenseStat ))*0.1)
		else
			---Default---
			M1Damage = math.max(npcDamage * (100/ (100 + targetDefenseStat)),
				math.floor(
					(1+ foundWeaponData.Damage / 100) * npcDamage) * ( 100 / ( 100 + targetDefenseStat )))
		end

	else
		
		---If target Blocking---
		if blocked then
			M1Damage = math.max(foundWeaponData.Damage * (100/ (100 + targetDefenseStat)),
				math.floor((
					(1+ foundWeaponData.Damage / 100) * playerDamageStat) * ( 100 / ( 100 + targetDefenseStat )))*0.1)
			
			---If Crit---	
		elseif playerCriticalDamageStat then
			M1Damage = math.max(foundWeaponData.Damage * (100/ (100 + targetDefenseStat)),
				math.floor((
					(1+ foundWeaponData.Damage / 100) * playerDamageStat) * ( 100 / ( 100 + targetDefenseStat )))) * playerCriticalDamageStat

		else
			---Default---
			M1Damage = math.max(foundWeaponData.Damage * (100/ (100 + targetDefenseStat)),
				math.floor((
					(1+ foundWeaponData.Damage / 100) * playerDamageStat) * ( 100 / ( 100 + targetDefenseStat ))))
		end	
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
	
	local AbilityDamage
	
	if npcDamage then
		
		if blocked then
			AbilityDamage =  math.max(npcDamage * (100/ (100 + targetDefenseStat)),
				math.floor(
					(( 1 + (abilityData.Damage) / 100) * npcDamage) * ( 100 / ( 100 + targetDefenseStat ))*0.1)) 
		else
			AbilityDamage = math.max(npcDamage * (100 / (100 + targetDefenseStat)),
				math.floor(
					( 1 + abilityData.Damage / 100) * npcDamage) * ( 100 / ( 100 + targetDefenseStat )))
		end
		
	else
		
		if blocked then
			AbilityDamage = math.max(abilityData.Damage * (100/ (100 + targetDefenseStat)),
				math.floor(
					(( 1 + abilityData.Damage / 100) * playerDamageStat) * ( 100 / ( 100 + targetDefenseStat ))*0.1))
		
		elseif playerCriticalDamageStat then
			AbilityDamage = math.max(abilityData.Damage * (100/ (100 + targetDefenseStat)),
				math.floor(
					(( 1 + abilityData.Damage / 100) * playerDamageStat) * ( 100 / ( 100 + targetDefenseStat )))) * playerCriticalDamageStat
			
		else
			
			AbilityDamage = math.max(abilityData.Damage * (100/ (100 + targetDefenseStat)),
				math.floor(
					(( 1 + abilityData.Damage / 100) * playerDamageStat) * ( 100 / ( 100 + targetDefenseStat ))))

		end
	end
	
	return AbilityDamage
end



return FormulaApplier
