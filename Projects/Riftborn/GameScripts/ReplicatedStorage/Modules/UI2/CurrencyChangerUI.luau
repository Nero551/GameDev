local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
return function(currencyFrame)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local yen = currencyFrame.YenNumber
	local Fracta = currencyFrame.FractaNumber

	NetworkingService:OnClientEvent("UpdateCurrency", function(playerCurrency)
		yen.Text = playerCurrency.Yen
		Fracta.Text = playerCurrency.Fracta
	end)
end
