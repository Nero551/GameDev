local DefualtPlayerData = {

	Inventory = {
		["weapon_0000000002"] = {
			Amount = 1,
			Mastery = 1,
			EXPRequired = 100,
			EXPAcquired = 0,
		},
		["armor_0000000001"] = {
			Amount = 1,
		},
	},
	Equipped = {
		Weapons = {
			MainHand = nil,
			OffHand = nil,
		},
		Armor = {
			Helmet = nil,
			ChestPlate = nil,
			Leggings = nil,
			Boots = nil,
		},
	},
	Stats = {
		MainStats = {
			Vitality = { Base = 10, FlatBuff = 0, FlatStatPoint = 0, Percent = 0, Final = 0 },
			Intelligence = { Base = 10, FlatBuff = 0, FlatStatPoint = 0, Percent = 0, Final = 0 },
			Strength = { Base = 10, FlatBuff = 0, FlatStatPoint = 0, Percent = 0, Final = 0 },
			Dexterity = { Base = 0, FlatBuff = 0, FlatStatPoint = 0, Percent = 0, Final = 0 },
			Agility = { Base = 0, FlatBuff = 0, FlatStatPoint = 0, Percent = 0, Final = 0 },
		},
		SubStats = {
			Defense = { Base = 0, FlatBuff = 0, FlatStatPoint = 0, Percent = 0, Final = 0 },
			CriticalDamage = { DexterityPercentBonus = 0, Percent = 0, Final = 0 },
			CriticalChance = { DexterityPercentBonus = 0, Percent = 0, Final = 0 },
		},
	},
	Level = {
		CurrentLevel = 1,
		RequiredEXP = 100,
		CurrentEXP = 0,
		StatPoints = 0,
	},
	Currency = {
		Yen = 0,
		Fracta = 0,
	},
	ItemPity = {},

	Quests = {
		ActiveQuests = {},
		CompletedQuests = {},
		TrackedQuest = nil,
	},
	Titles = {
		Titles = {},
		ActiveTitle = nil,
	},
	Buffs = {},

	Techniques = {
		Obtained = {},
		Equipped = {},
	},

	Keybinds = {
		MainHand = Enum.KeyCode.One.Name,
		OffHand = Enum.KeyCode.Two.Name,
		Technique1 = Enum.KeyCode.Z.Name,
		Technique2 = Enum.KeyCode.X.Name,
		Technique3 = Enum.KeyCode.C.Name,
		Technique4 = Enum.KeyCode.V.Name,
		Technique5 = Enum.KeyCode.B.Name,
		Technique6 = Enum.KeyCode.N.Name,
		Technique7 = Enum.KeyCode.R.Name,
		Technique8 = Enum.KeyCode.T.Name,
		Technique9 = Enum.KeyCode.G.Name,
		Technique10 = Enum.KeyCode.H.Name,
		Technique11 = Enum.KeyCode.Y.Name,
		Technique12 = Enum.KeyCode.U.Name,
	},
}

return DefualtPlayerData
