local AbilityData = {}

AbilityData.Z = {
	OnMouse = false,
	HitReaction = "1",
	BlockBreak = true,
	BlockDetoriation = nil,
	Damage = 10,
	Hits = 1,
	TimeBtwnHits = 0.2,
	AbilityCooldown = 10,
	HitBoxLookVector = 8,
	HitBoxSize = Vector3.new(5, 5.5, 70),
	HitBoxPosition = Vector3.new(0, 0, 0),
	HitBoxRotation = Vector3.new(0, 90, 0),
	Mana = 100,
	AbilityName = "Dimensional Cut",
	AbilityMastery = 0,
	AbilityRange = 10,
}

AbilityData.X = {
	OnMouse = false,
	HitReaction = "1",
	BlockBreak = false,
	BlockDetoriation = 1,
	Damage = 75,
	Hits = 2,
	TimeBtwnHits = 0.2,
	AbilityCooldown = 15,
	HitBoxLookVector = 10,
	HitBoxSize = Vector3.new(25, 44.5, 50),
	HitBoxPosition = Vector3.new(0, 15, 0),
	HitBoxRotation = Vector3.new(0, 90, 0),
	Mana = 200,
	AbilityName = "Dimensional Slash",
	AbilityMastery = 50,
	AbilityRange = 10,
}

AbilityData.C = {
	OnMouse = false,
	HitReaction = "1",
	BlockBreak = false,
	BlockDetoriation = 1,
	Damage = 10,
	Hits = 3,
	TimeBtwnHits = 0.2,
	AbilityCooldown = 1,
	HitBoxLookVector = 0,
	HitBoxSize = Vector3.new(19, 3.75, 19),
	HitBoxPosition = Vector3.new(0, 0, 0),
	HitBoxRotation = Vector3.new(0, 0, 0),
	Mana = 10,
	AbilityName = "Dimensional Spin",
	AbilityMastery = 100,
	AbilityRange = 10,
}

return AbilityData
