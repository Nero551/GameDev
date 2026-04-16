local FormulaApplier = {}

-- Default damage: slightly softer scaling, defense still reduces damage
function FormulaApplier:DefaultDamage(Damage, playerDamageStat, targetDefenseStat)
	return math.floor((Damage ^ 1.05 + playerDamageStat ^ 1.1) * (100 / (100 + targetDefenseStat)))
end

-- Blocked damage: now 25% of normal, feels more impactful than 10%
function FormulaApplier:BlockedDamage(Damage, playerDamageStat, targetDefenseStat)
	return math.floor((Damage ^ 1.05 + playerDamageStat ^ 1.1) * (100 / (100 + targetDefenseStat)) * 0.25)
end

-- Critical damage: critical multiplier added on top
function FormulaApplier:CriticalDamage(Damage, playerDamageStat, targetDefenseStat, CriticalDamageStat)
	return math.floor(
		(Damage ^ 1.05 + playerDamageStat ^ 1.1) * (100 / (100 + targetDefenseStat)) * (1 + CriticalDamageStat)
	)
end

-- BlackFlash damage: double critical effect
function FormulaApplier:BlackFlashDamage(Damage, playerDamageStat, targetDefenseStat, CriticalDamageStat)
	return math.floor(
		(Damage ^ 1.05 + playerDamageStat ^ 1.1) * (100 / (100 + targetDefenseStat)) * (1 + CriticalDamageStat * 2)
	)
end

return FormulaApplier
