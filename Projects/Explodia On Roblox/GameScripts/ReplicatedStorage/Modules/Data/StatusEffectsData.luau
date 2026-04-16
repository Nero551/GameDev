local StatusEffectsData = {}

StatusEffectsData.StatusEffects = {
	["Burn"] = {
		State = "Burning",
		Color = "#ff7a46",
		BaseDuration = 15,
		DamagePercent = 0.25,
		ProcEvery = 2.5,
		
	},

	["Freeze"] = {
		State = "Frozen",
		Color = "#27ffed",
		BaseDuration = 3,
		DamagePercent = 0.5,
		
	},	
	["Bleed"] = {
		State = "Bleeding",
		Color = "#8d080f",
		BaseDuration = 20,
		DamagePercent = 0.05,
		ProcEvery = 0.5
		
	}
}

return StatusEffectsData
