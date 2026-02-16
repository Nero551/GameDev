local StatusAilmentsData = {}

StatusAilmentsData.Ailments = {
	["Burn"] = {
		State = "Burning",
		Color = "#ff7a46",
		BaseDuration = 30,
		DamagePercent = 0.25,
		ProcEvery = 5,
	},
	["Poison"] = {
		State = "Poisoned",
		Color = "9b37ff",
		BaseDuration = 10, -- duration
		DamagePercent = 0.1, -- percent per proc
		ProcEvery = 2, -- seconds
	}
	
	
}

return StatusAilmentsData
