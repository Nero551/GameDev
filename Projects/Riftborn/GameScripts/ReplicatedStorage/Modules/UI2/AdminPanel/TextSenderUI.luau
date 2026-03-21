local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)

return function(textBox:TextBox)
	
	textBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			NetworkingService:FireToServer("AdminCommand", textBox.Text)
		end
	end)
end
