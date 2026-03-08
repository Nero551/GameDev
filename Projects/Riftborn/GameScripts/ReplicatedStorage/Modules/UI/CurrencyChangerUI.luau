local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
return function(currencyFrame)
	local repstor = game:GetService("ReplicatedStorage")
	local yen = currencyFrame.YenNumber
	local Fracta = currencyFrame.FractaNumber

	NetworkingService:OnClientEvent("UpdateCurrency", function(playerCurrency)
		yen.Text = playerCurrency.Yen
		Fracta.Text = playerCurrency.Fracta
	end)
end