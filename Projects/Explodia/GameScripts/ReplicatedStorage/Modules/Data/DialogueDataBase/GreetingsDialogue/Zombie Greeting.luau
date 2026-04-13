--? this one is the bit different, the scripts mostly just choose a random greeting instead of phases
--? u can still branch them tho and add options

local GreetingDialogueData = {
	["Greeting1"] = {
		Speaker = "Zombie",
		Lines = {
			{
				Text = "Hello mister , Are you nice?",
			},
		},
	},
	["Greeting2"] = {
		Speaker = "Zombie",
		Lines = {
			{
				Text = "Hello mister , eat nuts.",
			},
		},
	},
	["Greeting3"] = {
		Speaker = "Zombie",
		Lines = {
			{
				Text = "Hello mister , am deeply in love with you.",
			},
		},
	},
}

return GreetingDialogueData
