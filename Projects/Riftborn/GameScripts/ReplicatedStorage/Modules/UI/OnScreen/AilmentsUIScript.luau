
return function(ailmentsFrame:Frame)
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local StateChecker = require(script.Parent.Parent.Parent.StateChecker)
	
	local function AilmentsUI()
		for _,ailmentIcon in ailmentsFrame:GetChildren() do
			if ailmentIcon:IsA("ImageLabel") then
				if StateChecker:CheckState(char , ailmentIcon.Name) then
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