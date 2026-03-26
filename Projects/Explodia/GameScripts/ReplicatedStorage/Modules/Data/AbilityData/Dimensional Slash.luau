local module = {
	OnMouse = false,
	HitReaction = "1",
	BlockBreak = false,
	BlockDetoriation = 1,
	MinDamage = 20,
	MaxDamage = 25,
	Hits = 2,
	TimeBtwnHits = 0.2,
	AbilityCooldown = 15,
	HitBoxLookVector = 10,
	HitBoxSize = Vector3.new(25, 44.5, 50),
	HitBoxPosition = Vector3.new(0, 15, 0),
	HitBoxRotation = Vector3.new(0, 90, 0),
	Scaling = {
		Intelligence = 0.75,
		Strength = 0.25,
	},
	DamageType = "Magic",
	Cost = 200,
	AbilityName = "Dimensional Slash",
	AbilityMastery = 50,
}

return module
