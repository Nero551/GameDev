local StatusAilmentsData = {}

StatusAilmentsData.Ailments = {
	["Burn"] = {
		State = "Burning",
		Color = "#ff7a46",
		BaseDuration = 10,
		DamagePercent = 0.25,
		ProcEvery = 5,
		
	},
	["Poison"] = {
		State = "Poisoned",
		Color = "9b37ff",
		BaseDuration = 10, -- duration
		DamagePercent = 0.1, -- percent per proc
		ProcEvery = 2, -- seconds
	},
	["Freeze"] = {
		State = "Frozen",
		Color = "#27ffed",
		BaseDuration = 10,
		DamagePercent = 0.5,
		ProcEvery = 2.5,
		
	},	
	["Bleed"] = {
		State = "Bleeding",
		Color = "#8d080f",
		BaseDuration = 20,
		DamagePercent = 0.05,
		ProcEvery = 0.5
		
	}
}

return StatusAilmentsData
