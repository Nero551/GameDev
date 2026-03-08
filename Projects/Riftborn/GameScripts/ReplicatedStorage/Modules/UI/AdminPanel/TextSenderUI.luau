local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)

return function(textBox:TextBox)
	
	textBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			NetworkingService:FireToServer("AdminCommand", textBox.Text)
		end
	end)
end
