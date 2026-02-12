local repstor = game:GetService("ReplicatedStorage")
local titleDataBase = require(repstor.Modules.TitleData)
local GameEvents = require(repstor.Modules.GameEvents)
local DataService = require(script.Parent.Parent.ServerModules.DataService)

local TitleService = {}

function TitleService:SetupTitle(player)
	local playerTitles = Instance.new("Folder")
	playerTitles.Parent = player
	playerTitles.Name = "PlayerTitles"
	
	local activeTitle = Instance.new("StringValue")
	activeTitle.Parent = playerTitles
	activeTitle.Name = "ActiveTitle"
end

function TitleService:GetTitle(player, titleID)
	local playerTitles = DataService:GetTable(player, "Titles")
	if playerTitles.Titles[titleID] then return end
		local titleData = titleDataBase.Titles[titleID]
		if titleData then
			playerTitles.Titles[titleID] = titleData
		end
		
		repstor.Remotes.UpdateTitles:FireClient(player, playerTitles)	
		repstor.Remotes.PopUp:FireClient(player,{
			["TitleData"] = titleData 
		})
	return true
end

function TitleService:EquipTitle(player, titleID)
	local playerTitles = DataService:GetTable(player, "Titles")
	if not playerTitles.Titles[titleID] then return end
	
	TitleService:UnEquipTitle(player)
	
	playerTitles.ActiveTitle = titleID
	
	local buffs = playerTitles.Titles[titleID].Buffs
	if buffs then
		GameEvents.AddBuff:Fire(player ,  playerTitles.Titles[titleID], titleID)
	end
	
	
	player.PlayerTitles.ActiveTitle.Value = playerTitles.Titles[playerTitles.ActiveTitle].Name or ""
	repstor.Remotes.UpdateTitles:FireClient(player, playerTitles)	
end

function TitleService:UnEquipTitle(player)
	local playerTitles = DataService:GetTable(player, "Titles")
	if not playerTitles.ActiveTitle then return end
	
	local buffs = playerTitles.Titles[playerTitles.ActiveTitle].Buffs
	if buffs then
		GameEvents.RemoveBuff:Fire(player , playerTitles.Titles[playerTitles.ActiveTitle],playerTitles.ActiveTitle)
	end
	
	playerTitles.ActiveTitle = nil
	
	
	player.PlayerTitles.ActiveTitle.Value =  ""
	repstor.Remotes.UpdateTitles:FireClient(player, playerTitles)	
end

function TitleService:SyncTitlesWithTitleData(player)
	local playerTitles = DataService:GetTable(player, "Titles")
	for titleID, title in pairs(playerTitles.Titles) do
		local titleData = titleDataBase.Titles[titleID]
		if titleData then
			title.Name = titleData.Name
			title.Buffs = titleData.Buffs
			title.Color = titleData.Color
			
			if titleData.Buffs then
				if playerTitles.ActiveTitle == titleID then
					GameEvents.AddBuff:Fire(player , titleData, titleID)

				else
					GameEvents.RemoveBuff:Fire(player , titleData, titleID)
				end

			end
		else
			playerTitles.Titles[titleID] = nil
		end
	end
	
	if playerTitles.ActiveTitle == nil then
		player.PlayerTitles.ActiveTitle.Value = ""	
	else
		player.PlayerTitles.ActiveTitle.Value = playerTitles.Titles[playerTitles.ActiveTitle].Name
	end
	
	
	repstor.Remotes.UpdateTitles:FireClient(player, playerTitles)	
end

return TitleService
