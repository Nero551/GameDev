return function(chargeText)
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	
	local function UpdateUI()
		local currentFlashStep = char:GetAttribute("FlashStep_CurrentFlashStep")
		local maxFlashStep = char:GetAttribute("FlashStep_MaxFlashStep")
		if currentFlashStep and maxFlashStep then
			chargeText.Text = "Flashstep "..currentFlashStep.." / "..maxFlashStep
		end
	end
	char:GetAttributeChangedSignal("FlashStep_CurrentFlashStep"):Connect(UpdateUI)
	char:GetAttributeChangedSignal("FlashStep_MaxFlashStep"):Connect(UpdateUI)
	
	UpdateUI()
	
end