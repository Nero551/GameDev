--Armor Data Module
local ArmorData = {}

ArmorData.Armors = {
	                                                      --Helmets--
	--------------------------------------------------------------------------------------------------------------------------------------
	------Slime Head------
	["armor_0000000001"] = {
		Name = "Slime Head",
		Icon = "rbxassetid://70381584984142",
		Type = "Helmet",
		Rarity = "Uncommon",
		Description = "A friendly slime to keep you safe",
		Buffs = {
			Defense = { Percent = 0.5},
			Health = { Percent = 0.25},
			CriticalRate =  {Percent = 2},
			CriticalDamage = {Percent = 1},
		},
		
		Stackable = false,
		MaxStack = 1,	
	}
	,
	------Vision Head------
	["armor_0000000002"] = {
		Name = "Vision Head",
		Icon = "rbxassetid://83233832872691",
		Type = "Helmet",
		Rarity = "Rare",
		Description = "A helmet from the future.",
		Buffs = {
			Defense = { Percent = 0.5},
			Health = { Percent = 0.5},
			Mana = {Percent = 1}
		},
		Stackable = false,
		MaxStack = 1,	
	}
	,
	
		                                                      --ChestPlates--
	--------------------------------------------------------------------------------------------------------------------------------------
	------Flaming Tails------
	["armor_0000000003"] = {
		Name = "Flaming Tails",
		Icon = "rbxassetid://130377442600237",
		Type = "ChestPlate",
		Rarity = "Legendary",
		Description = "An Ancient Legendary Beast's Tails.",
		Buffs = {
			Defense = { Percent = 0.5},
			Health = { Percent = 0.5},
		},
		Stackable = false,
		MaxStack = 1,
	}
	,
		                                                      --Leggings--
	--------------------------------------------------------------------------------------------------------------------------------------
}

return ArmorData