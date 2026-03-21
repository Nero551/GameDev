local QuestData = require(game.ReplicatedStorage.Modules.Data.QuestData)

local QuestDialogueData = {}

QuestDialogueData["Start"] = {
	Speaker = "Zombie",
	Lines = {
		{
			Text =  "Ah, my back is killing me."
		},
		{
			Text = "Ya know the shiny blue colored crystals?"
		},
		{
			Text = "The cave is filled with those."
		},
		{
			Text = "Go get me some.",
			Options = {
				{
					Text = "Alright",
					Action = "AcceptQuest",
					Quest = QuestData:GetQuestID("Crystal Gathering")
				},
				{
					Text = "No",
					Next = "Refused Quest",

				}
			}
		},	
	}
}
QuestDialogueData["Accepted Quest"] = {
	Speaker = "Zombie",
	Lines = {
		{
			Text = "Good boy.",
		}	
	}
}
QuestDialogueData["Refused Quest"] = {
	Speaker = "Zombie",
	Lines = {
		{
			Text = "You suck.",
		}	
	}
}



QuestDialogueData["Middle"] = {
	Speaker = "Zombie",
	Lines = {
		{
			Text = "Why are you still here?",
			Options = {
				{
					Text = "Where can i find the crystals?",
					Next = "HelpingPlayer",
				}
			}
		},

	}
}

QuestDialogueData["HelpingPlayer"] = {
	Speaker = "Zombie",
	Lines = {
		{
			Text = "I told you dumbass , u find them in the cave.",
			Options = {
				{
					Text = "Thanks. also dont be so mean.",
					Next = "OrderingPlayer",
				}
			}
		},
	}
}


QuestDialogueData["OrderingPlayer"] = {
	Speaker = "Zombie",
	Lines = {
		{
			Text = "Now go get the crystals monkey."
		}
	}
}

QuestDialogueData["End"] = {
	Speaker = "Zombie",
	Lines = {
		{
			Text = "Oh, you actually got them.",
		},
		{
			Text = "I didn't expect you to actually get them.",
		},
		{
			Text = "Well, thanks a lot traveler.",
			Options = {
				{
					Text = "Need something else?",
					Action = "ContinueDialogue"
				},
				{
					Text = "See ya",
					Action = "EndDialogue"
				}
			}
		},
		{
			Text = "Bye.",
		}
	}

}

return QuestDialogueData
