--Weapon Data Module


local WeaponData = {}

WeaponData.Weapons = {
	------Fist------
	["weapon_0000000001"] = {
		Name = "Fist",
		Icon = "rbxassetid://2245735821",
		Type = "Melee",
		Rarity = "Rare",
		Description = "Can't even hit your target berarebones? noob.",
		StatusAilments = {
			ProcChance = 0.1,
			Effects = {
				"Burn",
			},
		},
		Damage = 5,
		ComboCooldown = 2,
		ComboResetTime = 2,
		CriticalRate = 0.1,
		CriticalDamage = 1,
		Stackable = false,
	}
	,
	------CidSword------
	["weapon_0000000002"] = {
		Name = "Cid Sword",
		Icon = "rbxassetid://84373910714543",
		Type = "Sword",
		Rarity = "Mythical",
		Description = "A blade forged from slime. Previously wielded by the eminence in shadow.",
		Damage = 1,
		ComboCooldown = 2,
		ComboResetTime = 2,
		CriticalRate = 0.25,
		CriticalDamage = 1,
		Stackable = false,
	}
	,
	------Sword------
	["weapon_0000000003"] = {
		Name = "Katana",
		Icon = "rbxassetid://84373910714543",
		Type = "Sword",
		Rarity = "Common",
		Description = "Just a normal blade....dont put it in your mouth please.",
		Damage = 2,
		ComboCooldown = 2,
		ComboResetTime = 2,
		CriticalRate = 0.25,
		CriticalDamage = 1,
		Stackable = false,
	}
	,
	------Dagger------
	["weapon_0000000004"] = {
		Name = "Dagger",
		Icon = "rbxassetid://84373910714543",
		Type = "Sword",
		Rarity = "Uncommon",
		Description = "OpDagger.",
		Damage = 2000,
		ComboCooldown = 2,
		ComboResetTime = 2,
		CriticalRate = 0.25,
		CriticalDamage = 1,
		Stackable = false,
	}
	,
	
}

return WeaponData