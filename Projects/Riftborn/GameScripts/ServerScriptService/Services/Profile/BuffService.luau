local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = require(game.ServerScriptService.Services.Profile.DataService)
local StatService = require(script.Parent.StatService)
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local TitleData = require(ReplicatedStorage.Modules.Data.TitleData)

local BuffService = {}

function BuffService:UpdateBuffs(player)
	StatService:ResetBuffs(player)
	local playerBuffs = DataService:GetTable(player, "Buffs")
	for buffID, buffInfo in pairs(playerBuffs) do
		local data = ItemDataBase:GetItemData(buffID) or TitleData.Titles[buffID]
		if not data then return end
		if  data.Buffs then 
			buffInfo.Buffs = data.Buffs
			buffInfo.Type = data.Type or nil
			StatService:ApplyBuffs(player, buffInfo.Buffs)
		else
			playerBuffs[buffID] = nil
		end		
	end
end

function BuffService:AddBuff(player:Player, data, ID)
	local playerBuffs = DataService:GetTable(player, "Buffs")
	if not data.Buffs then return end
	if  playerBuffs[ID] then return end
	playerBuffs[ID] = {
		Type = data.Type,
		Buffs = data.Buffs,
		Duration = data.Duration or nil
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
