local MobData = {}
MobData.Mobs = {
	["Zombie"] = {
		Type = "Enemy",
		Tool = "weapon_0000000002", -- Cid Sword
		Wander = false,
		WanderRadius = 50,
		DetectionRange = 100,
		AttackRange = 6,
		WalkSpeed = 10,
		RunSpeed = 32,
		MinDamage = 2,
		MaxDamage = 2.2,
		MinHealth = 100,
		MaxHealth = 150,
		Techniques = {
			"technique_0000000001",
			"technique_0000000002",
			"technique_0000000003",
		},
		Drops = {
			["Yen"] = 1000,
			["Fracta"] = 20,
			["EXP"] = 2000,
			["MasteryEXP"] = 20000,
			ItemDrops = {
				["Blue Crystal"] = {Amount =  1},
				["Flaming Tails"] = {Amount =  1},
				["Cid Sword"] = {Amount =  1},
				["Vision Head"] = {Amount =  1},
			}
		}
	}
	,	
		["Villager"] = {
		Type = "Quest",
		Tool = "weapon_0000000001", -- Fist
		Wander = true,
		WanderRadius = 100,
		DetectionRange = 10,
		AttackRange = 6,
		WalkSpeed = 10,
		RunSpeed = 24,
		MinDamage = 0.8,
		MaxDamage = 1,
		MinHealth = 50,
		MaxHealth = 100,
		Drops = {
			["Yen"] = 5,
			["EXP"] = 50,
			["MasteryEXP"] = 100,
		}
	}
	,	
}


return MobData
