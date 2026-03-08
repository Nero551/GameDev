local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
local repstor = game:GetService("ReplicatedStorage")
local titleDataBase = require(repstor.Modules.Data.TitleData)
local GameEvents = require(repstor.Modules.GameEvents)
local DataService = require(script.Parent.Parent.Services.DataService)

local TitleService = {}

function TitleService:SetupTitle(player)
	local playerTitles = DataService:GetTable(player, "Titles")
	local TitlesFolder = player:FindFirstChild("PlayerTitles")
	
	if not TitlesFolder then
		TitlesFolder = Instance.new("Folder")
		TitlesFolder.Parent = player
		TitlesFolder.Name = "PlayerTitles"

		local activeTitle = Instance.new("StringValue")
		activeTitle.Parent = TitlesFolder
		activeTitle.Name = "ActiveTitle"
	end
	NetworkingService:FireToClient(player, "UpdateTitles", playerTitles)
end

function TitleService:GetTitle(player, titleID)
	local playerTitles = DataService:GetTable(player, "Titles")
	if playerTitles.Titles[titleID] then return end
		local titleData = titleDataBase.Titles[titleID]
		if titleData then
			playerTitles.Titles[titleID] = titleData
		end
		
		NetworkingService:FireToClient(player, "UpdateTitles", playerTitles)	
		NetworkingService:FireToClient(player, "PopUp", {
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
	NetworkingService:FireToClient(player, "UpdateTitles", playerTitles)	
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
	NetworkingService:FireToClient(player, "UpdateTitles", playerTitles)	
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
end

return TitleService
