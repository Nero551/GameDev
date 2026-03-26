local module = {
	OnMouse = false,
	HitReaction = "1",
	BlockBreak = true,
	BlockDetoriation = nil,
	MinDamage = 10,
	MaxDamage = 15,
	Hits = 1,
	TimeBtwnHits = 0.2,
	AbilityCooldown = 10,
	HitBoxLookVector = 8,
	HitBoxSize = Vector3.new(5, 5.5, 70),
	HitBoxPosition = Vector3.new(0, 0, 0),
	HitBoxRotation = Vector3.new(0, 90, 0),
	Scaling = {
		Intelligence = 0.75,
		Dexterity = 0.25,
	},
	DamageType = "Magic",
	Cost = 100,
	AbilityName = "Dimensional Cut",
	AbilityMastery = 0,
}

return module
