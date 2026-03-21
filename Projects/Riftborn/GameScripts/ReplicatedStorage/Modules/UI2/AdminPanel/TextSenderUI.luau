local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local NetworkingService = ModuleLoader:Load("Shared", "NetworkingService")

return function(textBox:TextBox)
	
	textBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			NetworkingService:FireToServer("AdminCommand", textBox.Text)
		end
	end)
end
