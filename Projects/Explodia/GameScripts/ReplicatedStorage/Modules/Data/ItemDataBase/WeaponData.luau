--Weapon Data
local WeaponData = {}

WeaponData.Weapons = {
	------Fist------
	["weapon_0000000001"] = {
		Name = "Fist",
		Icon = "rbxassetid://2245735821",
		Type = "Melee",
		Rarity = "Common",
		Description = "Can't even hit your target barebones? noob.",
		StatusEffects = {
			ProcChance = 0.5,
			Effects = {
				"Burn",
			},
		},
		Scaling = {
			Strength = 0.6,
			Vitality = 0.2,
			Agility = 0.2,
		},
		MinDamage = 1,
		MaxDamage = 2,
		Hitbox = Vector3.new(5, 5.5, 4),
		ComboCooldown = 2,
		ComboResetTime = 2,
		CriticalChance = 0.5,
		CriticalDamage = 1,
		Stackable = false,
	},
	------CidSword------
	["weapon_0000000002"] = {
		Name = "Cid Sword",
		Icon = "rbxassetid://84373910714543",
		Type = "Sword",
		Rarity = "Mythical",
		Description = "A blade forged from slime. Previously wielded by the eminence in shadow.",
		MinDamage = 5,
		MaxDamage = 10,
		Hitbox = Vector3.new(5, 5.5, 4),
		Scaling = {
			Strength = 0.6,
			Vitality = 0.2,
			Agility = 0.2,
		},
		ComboCooldown = 2,
		ComboResetTime = 2,
		CriticalChance = 0.25,
		CriticalDamage = 1,
		Stackable = false,
	},
	------Sword------
	["weapon_0000000003"] = {
		Name = "Katana",
		Icon = "rbxassetid://84373910714543",
		Type = "Sword",
		Rarity = "Common",
		Description = "Just a normal blade....dont put it in your mouth please.",
		Damage = 2,
		Scaling = {
			Strength = 0.6,
			Vitality = 0.2,
			Agility = 0.2,
		},
		Hitbox = Vector3.new(5, 5.5, 4),
		ComboCooldown = 2,
		ComboResetTime = 2,
		CriticalChance = 4,
		CriticalDamage = 1,
		Stackable = false,
	},
	------Dagger------
	["weapon_0000000004"] = {
		Name = "Dagger",
		Icon = "rbxassetid://84373910714543",
		Type = "Sword",
		Rarity = "Uncommon",
		Description = "OpDagger.",
		Damage = 2000,
		Scaling = {
			Strength = 0.6,
			Vitality = 0.2,
			Agility = 0.2,
		},
		Hitbox = Vector3.new(5, 5.5, 4),
		ComboCooldown = 2,
		ComboResetTime = 2,
		CriticalChance = 0.25,
		CriticalDamage = 1,
		Stackable = false,
	},
}

return WeaponData
