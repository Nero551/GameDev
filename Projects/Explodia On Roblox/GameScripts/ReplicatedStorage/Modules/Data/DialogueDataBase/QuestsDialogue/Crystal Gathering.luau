local QuestData = require(game.ReplicatedStorage.Modules.Data.QuestData)

local QuestDialogueData = {

	--? Start phase
	["Start"] = {
		Speaker = "Villager",
		Lines = {
			{
				Text = "Ah, my back is killing me.", --? First Line the VILLAGER Says
			},
			{
				Text = "Ya know the shiny blue colored crystals?", --? Second
			},
			{
				Text = "The cave is filled with those.", --? Third
			},
			{
				Text = "Go get me some.", --? Fourth , this one gives two options to the player.
				Options = {
					--? Option1
					{
						Text = "Alright", --? Option1's text (wut u say)
						Action = "AcceptQuest", --? What this action will do,dialogueService handles this
						Quest = QuestData:GetQuestID("Crystal Gathering"), --?? Extra data to help dialogueService
					},
					--? Option2
					{
						Text = "No", --? Option2's text (wut u say)
						Next = "Refused Quest", --? the name of the next dialogue set
					},
				},
			},
		},
	},

	--? supporting phase/ dialogue set
	["Accepted Quest"] = {
		Speaker = "Villager",
		Lines = {
			{
				Text = "Good boy.",
			},
		},
	},

	--? supporting phase/ dialogue set
	--? Option2 in Start Phase leads to this
	["Refused Quest"] = {
		Speaker = "Villager",
		Lines = {
			{
				Text = "You suck.",
			},
		},
	},

	--? Middle phase , same stuff just middle phase
	["Middle"] = {
		Speaker = "Villager",
		Lines = {
			{
				Text = "Why are you still here?",
				Options = {
					{
						Text = "Where can i find the crystals?",
						Next = "HelpingPlayer", --? leads to helping player dialogue set
					},
				},
			},
		},
	},

	--? supporting phase/ dialogue set
	--? middle phase option 1 leads to this
	--? u can nest supporting phases as shown down in option1 of helping player
	["HelpingPlayer"] = {
		Speaker = "Villager",
		Lines = {
			{
				Text = "I told you dumbass , u find them in the cave.",
				Options = {
					{
						Text = "Thanks. also dont be so mean.",
						Next = "OrderingPlayer", --? yes supporting phases can lead to more supporting phases
					},
				},
			},
		},
	},

	--? supporting phase helping player leads to this
	["OrderingPlayer"] = {
		Speaker = "Villager",
		Lines = {
			{
				Text = "Now go get the crystals monkey.",
			},
		},
	},

	--? End phase
	["End"] = {
		Speaker = "Villager",
		Lines = {
			{
				Text = "Oh, you actually got them.",
			},
			{
				Text = "I didn't expect you to actually get them.",
			},
			{
				Text = "Well, thanks a lot traveler.",
			},
			{
				Text = "Bye.",
			},
		},
	},
}

return QuestDialogueData
