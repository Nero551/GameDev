return function(DialogueFrame)
	local player = game:GetService("Players").LocalPlayer
	local repstor = game:GetService("ReplicatedStorage")

	local DialogueText = DialogueFrame.DialogueText
	local SpeakerName = DialogueFrame.SpeakerName
	local Texture = DialogueFrame.Texture

	local skipLine = false
	local canClick = true

	Texture.MouseButton1Click:Connect(function()
		if skipLine == true and canClick == true then
			repstor.Remotes.ContinueDialogue:FireServer(player)
		end
		skipLine = true
	end)

	local function PlayLine(speaker, line)
		DialogueFrame.Visible = true
		SpeakerName.Text = speaker
		DialogueText.Text = ""

		skipLine = false
		local i = 0
		local length = #line

		while i < length do
			i += 1
			DialogueText.Text = string.sub(line, 1, i)
			repstor.Assets.Sounds.DialogueSound:Play()
			if skipLine then
				DialogueText.Text = line
				break
			end
			wait(0.03)
		end
		skipLine = true
	end

	repstor.Remotes.ShowDialogue.OnClientEvent:Connect(function(speaker, dialogueData, ended)
		if ended then
			DialogueFrame.Visible = false
			SpeakerName.Text = ""
			DialogueText.Text = ""
			return
		end

		for _,optionButton in DialogueFrame.OptionFrame:GetChildren() do
			if optionButton:IsA("ImageButton") then
				optionButton:Destroy()
			end
		end

		PlayLine(speaker, dialogueData.Text)

		if dialogueData.Options then

			for option,optioninfo in pairs(dialogueData.Options) do
				local optionButton:ImageButton? = repstor.Assets.GUI.DialogueOption:Clone()
				optionButton.Name = option
				optionButton.Text.Text = optioninfo.Text
				optionButton.Parent = DialogueFrame.OptionFrame
				optionButton.MouseButton1Click:Connect(function()
					repstor.Remotes.SelectDialogueOption:FireServer(option)
				end)
			end		
			canClick = false
		else
			canClick = true
		end

	end)

end