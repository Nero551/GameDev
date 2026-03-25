local MobData = {}
MobData.Mobs = {
	["Zombie"] = {
		Type = "Enemy",
		Tool = "weapon_0000000002", -- Fist
		Wander = true,
		WanderRadius = 50,
		DetectionRange = 100,
		AttackRange = 6,
		WalkSpeed = 10,
		RunSpeed = 32,
		MinDamage = 1,
		MaxDamage = 2,
		MinHealth = 100,
		MaxHealth = 150,
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
}


return MobData
