return function(text)
	local Player = game:GetService("Players").LocalPlayer
	local char = Player.Character or Player.CharacterAdded:Wait()
	local StateChecker = require(script.Parent.Parent.Parent.StateChecker)
	local statusFolder = char:WaitForChild("Status")
	
	statusFolder.ChildAdded:Connect(function()
		if StateChecker:CheckState(char, "In Combat") then
			text.Visible = true

		else
			text.Visible = false
		end
	end)
	
	statusFolder.ChildRemoved:Connect(function()
		if StateChecker:CheckState(char, "In Combat") then
			text.Visible = true

		else
			text.Visible = false
		end
	end)
end