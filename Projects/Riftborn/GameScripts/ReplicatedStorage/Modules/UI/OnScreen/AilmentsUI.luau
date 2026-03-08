
return function(ailmentsFrame:Frame)
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local StateChecker = require(script.Parent.Parent.Parent.StateChecker)
	
	local function AilmentsUI()
		for _,ailmentIcon in ailmentsFrame:GetChildren() do
			if ailmentIcon:IsA("ImageLabel") then
				if StateChecker:CheckState(char , ailmentIcon.Name) then
					ailmentIcon.Visible = true
					if char:WaitForChild("Status"):FindFirstChild(ailmentIcon.Name):GetAttribute("Duration") then
						ailmentIcon.Duration.Text = math.floor(
							char:WaitForChild("Status"):FindFirstChild(ailmentIcon.Name):GetAttribute("Duration"))
					end
				else
					ailmentIcon.Visible = false
				end
			end
		end
	end
	
	char.AttributeChanged:Connect(function()
		AilmentsUI()
	end)
	AilmentsUI()
	
end