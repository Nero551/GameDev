local repstor = game:GetService("ReplicatedStorage")
local modules =  repstor.Modules
local remotes = repstor.Remotes

local AdminCmdsService = require(script.Parent.Parent.Services.AdminCmdsService)

local ADMIN_IDS = require(modules.Data.AdminIDs)

---COMMANDS---
remotes.AdminCommand.OnServerEvent:Connect(function(player, msg)
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
