local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = ModuleLoader:Load("Server", "DataService")
local StatService = ModuleLoader:Load("Server", "StatService")
local ItemDataBase = ModuleLoader:Load("Shared", "ItemDataBase")
local TitleData = ModuleLoader:Load("Shared", "TitleData")

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
