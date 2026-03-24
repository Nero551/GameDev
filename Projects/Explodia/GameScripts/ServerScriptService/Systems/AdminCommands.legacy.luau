local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local AdminCmdsService = require(game.ServerScriptService.Services.Core.AdminCmdsService)

local ADMIN_IDS = require(game.ReplicatedStorage.Modules.Data.AdminIDs)

---COMMANDS---
NetworkingService:OnServerEvent("AdminCommand", function(player, msg)
	if not ADMIN_IDS[player.UserId] then return end
	local msgParts = msg:split(" ")
	
	if msgParts[1] == "/deletedata" then
		AdminCmdsService:DeleteData(msgParts)
	end

	if msgParts[1] == "/printdata" then
		AdminCmdsService:PrintData(msgParts)
	end

	if msgParts[1] == "/exp"  then
		AdminCmdsService:GainEXP(msgParts)
	end

	if msgParts[1] == "/give" then
		AdminCmdsService:GiveItem(msgParts)
	end

	if msgParts[1] == "/remove" then
		AdminCmdsService:RemoveItem(msgParts)
	end

	if msgParts[1] == "/get" then
		AdminCmdsService:GetTitle(msgParts)
	end
	
	if msgParts[1] == "/state" then
		AdminCmdsService:ApplyState(msgParts)
	end
end)
