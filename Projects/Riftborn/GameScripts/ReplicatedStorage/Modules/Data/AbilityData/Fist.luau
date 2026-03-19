local AbilityData = {}

AbilityData.V = {
	OnMouse = false,
	HitReaction = "1",
	BlockBreak = false,
	BlockDetoriation = 1,
	Damage = 50,
	Hits = 3,
	TimeBtwnHits = 0.2,
	AbilityCooldown = 20,
	HitBoxLookVector = 0,
	HitBoxSize = Vector3.new(15, 3.75, 15),
	HitBoxPosition = Vector3.new(0, 0, 0),
	HitBoxRotation = Vector3.new(0, 0, 0),
	Mana = 50,
	AbilityName = "Honored One",
	AbilityMastery = 100,
	AbilityRange = 10,
}

return AbilityData
