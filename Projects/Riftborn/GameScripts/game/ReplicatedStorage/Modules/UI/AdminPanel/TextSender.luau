return function(textBox:TextBox)
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local adminCommand = replicatedStorage.Remotes.AdminCommand
	
	textBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			adminCommand:FireServer(textBox.Text)
		end
	end)
end