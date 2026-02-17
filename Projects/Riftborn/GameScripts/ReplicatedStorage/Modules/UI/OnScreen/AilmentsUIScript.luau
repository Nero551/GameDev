
return function(ailmentsFrame:Frame?)
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local stateService = require(script.Parent.Parent.Parent.StateService)
	local statusFolder = char:WaitForChild("Status")
	
	local function AilmentsUI()
		for _,ailmentIcon in ailmentsFrame:GetChildren() do
			if ailmentIcon:IsA("ImageLabel") then
				if stateService.checkState(char , ailmentIcon.Name) then
					ailmentIcon.Visible = true
					ailmentIcon.Duration.Text = math.floor(char:GetAttribute("StatusAilments_"..ailmentIcon.Name.."_Duration"))

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