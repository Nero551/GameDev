local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
return function(button:TextButton?, frame:Frame?)
	local AdminIDs = ModuleLoader:Load("Shared", "AdminIDs")
	local Player = game:GetService("Players").LocalPlayer
	if not AdminIDs[Player.UserId] then
		button.Visible = false
		return
	end
	
	button.Visible = true
	
	button.MouseButton1Click:Connect(function()
		if frame.Visible == true then
			frame.Visible = false

		else
			frame.Visible =  true
		end
	end)
end
