return function(currencyFrame)
	local repstor = game:GetService("ReplicatedStorage")
	local yen = currencyFrame.YenNumber
	local Fracta = currencyFrame.FractaNumber

	repstor.Remotes.UpdateCurrency.OnClientEvent:Connect(function(playerCurrency)
		yen.Text = playerCurrency.Yen
		Fracta.Text = playerCurrency.Fracta
	end)
end