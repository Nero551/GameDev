return function(chargeText)
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local statusFolder = char:WaitForChild("Status")
	local ChargeValue:IntValue = statusFolder:WaitForChild("FlashStepCharge")
	ChargeValue.Changed:Connect(function()
		chargeText.Text = "FlashStep "..ChargeValue.Value.." / "..3
	end)
end