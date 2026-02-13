local repstor = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.Parent.Services.DataService)
local statService = require(script.Parent.StatService)
local itemDataBase = require(repstor.Modules.Data.ItemDataBase)
local titleDataBase = require(repstor.Modules.Data.TitleData)

local BuffService = {}

function BuffService:UpdateBuffs(player)
	statService:ResetBuffs(player)
	local playerBuffs = DataService:GetTable(player, "Buffs")
	for buffID, buffInfo in pairs(playerBuffs) do
		local data = itemDataBase:GetItemData(buffID)
		if not data then
			data = titleDataBase.Titles[buffID]
		end
		if  data.Buffs then 
			buffInfo.Buffs = data.Buffs
			buffInfo.Type = data.Type or nil
			
		else
			_G.playerBuffs[player][buffID] = nil
		end		
		
		statService:ApplyBuffs(player, buffInfo.Buffs)
	end
end

function BuffService:AddBuff(player:Player, data, ID)
	local playerBuffs = DataService:GetTable(player, "Buffs")
	if not data.Buffs then return end
	if  playerBuffs[ID] then return end
	playerBuffs[ID] = {
		Type = data.Type,
		Buffs = data.Buffs
	}
	BuffService:UpdateBuffs(player)
end

function BuffService:RemoveBuff(player,data,ID)
	local playerBuffs = DataService:GetTable(player, "Buffs")
	if not data.Buffs then return end
	if  not playerBuffs[ID] then return end
	playerBuffs[ID] = nil
	BuffService:UpdateBuffs(player)
end



return BuffService
