local repstor = game:GetService("ReplicatedStorage")
local DataService = require(script.Parent.Parent.ServerModules.DataService)

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
	repstor.Remotes.UpdateCurrency:FireClient(player ,playerCurrency)
	repstor.Remotes.PopUp:FireClient(player,{
		["Currency"] = currency,
		["CurrencyAmount"] = amount,
	})
end

return CurrencyService
