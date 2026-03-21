local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local DataService = require(game.ServerScriptService.Services.Profile.DataService)

local CurrencyService = {}

function CurrencyService:SetupCurrencies(player)
	local playerCurrency = DataService:GetTable(player, "Currency")
	local folder = player:FindFirstChild("Currencies")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Currencies"
		folder.Parent = player
	end

	for currency,amount in pairs(playerCurrency) do
		local value = folder:FindFirstChild(currency)
		if not value then
			value = Instance.new("StringValue")
			value.Name = currency
			value.Parent = folder
		end
		value:SetAttribute("Amount", amount)
	end
end

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

		local folder = player:FindFirstChild("Currencies")
		local value = folder:FindFirstChild(currency)
		if value:GetAttribute("Amount") ~= playerCurrency[currency] then
			value:SetAttribute("Amount", playerCurrency[currency])
		end
	end
	NetworkingService:FireToClient(player, "PopUp", {
		["Currency"] = currency,
		["CurrencyAmount"] = amount,
	})
end

return CurrencyService
