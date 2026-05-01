local DimensionalSet = {

	["technique_0000000001"] = {
		TechniqueName = "Dimensional Cut",
		Description = "A Slash That Cuts Through Dimensions.",

		Cost = 10,
		Mastery = 0,

		Type = "Normal",
		HitReaction = "1",

		BlockBreak = true,
		BlockDetoriation = nil,

		MinDamage = 10,
		MaxDamage = 15,
		Hits = 1,
		DamageType = "Magic",

		TimeBtwnHits = 0.2,
		Cooldown = 10,

		HitBoxLookVector = 8,
		HitBoxSize = Vector3.new(5, 5.5, 70),
		HitBoxPosition = Vector3.new(0, 0, 0),
		HitBoxRotation = Vector3.new(0, 90, 0),
		Scaling = {
			Intelligence = 0.75,
			Dexterity = 0.25,
		},

		AllowedWeaponSubTypes = {
			"Sword",
		},
	},
	["technique_0000000002"] = {
		TechniqueName = "Dimensional Slash",
		Description = "",

		Cost = 10,
		Mastery = 50,

		Type = "Normal",
		HitReaction = "1",

		BlockBreak = false,
		BlockDetoriation = 1,

		MinDamage = 20,
		MaxDamage = 25,
		Hits = 2,
		DamageType = "Magic",

		TimeBtwnHits = 0.2,
		Cooldown = 15,

		HitBoxLookVector = 10,
		HitBoxSize = Vector3.new(25, 44.5, 50),
		HitBoxPosition = Vector3.new(0, 15, 0),
		HitBoxRotation = Vector3.new(0, 90, 0),
		Scaling = {
			Intelligence = 0.75,
			Strength = 0.25,
		},

		AllowedWeaponSubTypes = {
			"Sword",
		},
	},
	["technique_0000000003"] = {
		TechniqueName = "Dimensional Spin",
		Description = "",

		Cost = 10,
		Mastery = 100,

		Type = "Normal",
		HitReaction = "1",

		BlockBreak = false,
		BlockDetoriation = 1,

		MinDamage = 10,
		MaxDamage = 15,
		Hits = 3,
		DamageType = "Physical",

		TimeBtwnHits = 0.2,
		Cooldown = 5,

		HitBoxLookVector = 0,
		HitBoxSize = Vector3.new(19, 3.75, 19),
		HitBoxPosition = Vector3.new(0, 0, 0),
		HitBoxRotation = Vector3.new(0, 0, 0),
		Scaling = {
			Intelligence = 0.75,
			Agility = 0.25,
		},

		AllowedWeaponSubTypes = {
			"Sword",
		},
	},
}

return DimensionalSet
