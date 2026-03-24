local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataService = require(ServerScriptService.Services.Core.DataService)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local MasteryService = {}

function MasteryService:IncreaseMastery(player: Player, itemID, masteryEXP)
    local maxMastery = 600
	local inventory = DataService:GetTable(player, "Inventory")
	local item = inventory[itemID]
	if not item then
		return
	end
	if not item.Mastery or not item.EXPRequired or not item.EXPAcquired then
		return
	end

    local value = player:WaitForChild("Inventory"):FindFirstChild(itemID)

    item.EXPAcquired += masteryEXP
	task.spawn(function()
		while item.EXPAcquired >= item.EXPRequired do
            if item.Mastery >= maxMastery then
                item.Mastery = maxMastery
				item.RequiredEXP = math.floor(100 * (maxMastery ^ 1.9))
                item.EXPAcquired = item.EXPRequired
                return  
            end

            item.Mastery += 1
            item.EXPAcquired -= item.EXPRequired
			item.EXPRequired = math.floor(100 * (item.Mastery ^ 1.9))

			NetworkingService:FireToClient(player, "PopUp", {
                ["ID"] = itemID,
				["Mastery"] = item.Mastery,
			})

			value:SetAttribute("Mastery", item.Mastery)
			value:SetAttribute("EXPAcquired", item.EXPAcquired)
			value:SetAttribute("EXPRequired", item.EXPRequired)
            task.wait(0.1)
		end
	end)
    value:SetAttribute("Mastery", item.Mastery)
    value:SetAttribute("EXPAcquired", item.EXPAcquired)
    value:SetAttribute("EXPRequired", item.EXPRequired)

    if masteryEXP > 0 then
		NetworkingService:FireToClient(player, "PopUp", {
			["ID"] = itemID,
			["MasteryEXP"] = masteryEXP,
		})
    end
end

return MasteryService
