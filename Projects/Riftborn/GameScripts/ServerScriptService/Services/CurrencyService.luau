local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
local repstor = game:GetService("ReplicatedStorage")
local DataService = require(script.Parent.Parent.Services.DataService)

local CurrencyService = {}

function CurrencyService:CurrencyChange(player , currency, amount)
	local playerCurrency = DataService:GetTable(player, "Currency")
	if playerCurrency[currency] then
		if type(amount) == "number" then
			if playerCurrency[currency] + amount < 0 then
				playerCurrency[currency] = 0
			else
				playerCurrency[currency] += amount
			end
		end
	end
	NetworkingService:FireToClient(player , "UpdateCurrency", playerCurrency)
	NetworkingService:FireToClient(player, "PopUp", {
		["Currency"] = currency,
		["CurrencyAmount"] = amount,
	})
end

return CurrencyService
