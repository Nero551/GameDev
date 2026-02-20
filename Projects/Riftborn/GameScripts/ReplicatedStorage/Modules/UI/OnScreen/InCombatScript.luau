return function(text)
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local stateService = require(script.Parent.Parent.Parent.StateService)
	local statusFolder = char:FindFirstChild("Status")
	
	statusFolder.ChildAdded:Connect(function()
		if stateService.checkState(char, "In Combat") then
			text.Visible = true

		else
			text.Visible = false
		end
	end)
	
	statusFolder.ChildRemoved:Connect(function()
		if stateService.checkState(char, "In Combat") then
			text.Visible = true

		else
			text.Visible = false
		end
	end)
end