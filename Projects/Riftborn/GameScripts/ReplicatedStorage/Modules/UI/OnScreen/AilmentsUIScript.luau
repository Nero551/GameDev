
return function(ailmentsFrame:Frame?)
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local stateService = require(script.Parent.Parent.Parent.StateService)
	local statusFolder = char:WaitForChild("Status")
	
	for _,ailmentIcon in ailmentsFrame:GetChildren() do
		if ailmentIcon:IsA("ImageLabel") then
			char:GetAttributeChangedSignal("StatusAilments_"..ailmentIcon.Name.."_Duration"):Connect(function()	
				task.wait(0.1)
				
				if stateService.checkState(char , ailmentIcon.Name) then
					ailmentIcon.Visible = true
					ailmentIcon.Duration.Text = math.max(0, math.floor(char:GetAttribute("StatusAilments_"..ailmentIcon.Name.."_Duration")))

				else
					ailmentIcon.Visible = false
				end
			end)
		end
	end
end