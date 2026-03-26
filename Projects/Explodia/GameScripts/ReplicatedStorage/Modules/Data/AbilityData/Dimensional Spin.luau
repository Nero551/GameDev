local module = {
	OnMouse = false,
	HitReaction = "1",
	BlockBreak = false,
	BlockDetoriation = 1,
	MinDamage = 10,
	MaxDamage = 15,
	Hits = 3,
	TimeBtwnHits = 0.2,
	AbilityCooldown = 5,
	HitBoxLookVector = 0,
	HitBoxSize = Vector3.new(19, 3.75, 19),
	HitBoxPosition = Vector3.new(0, 0, 0),
	HitBoxRotation = Vector3.new(0, 0, 0),
	Scaling = {
		Intelligence = 0.75,
		Agility = 0.25,
	},
	DamageType = "Physical",
	Cost = 10,
	AbilityName = "Dimensional Spin",
	AbilityMastery = 100,
}

return module
