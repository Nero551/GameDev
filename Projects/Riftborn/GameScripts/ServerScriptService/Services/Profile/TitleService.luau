local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local TitleData = require(game.ReplicatedStorage.Modules.Data.TitleData)
local GameEvents = require(game.ReplicatedStorage.Modules.Core.GameEvents)
local DataService = require(game.ServerScriptService.Services.Profile.DataService)

local TitleService = {}

function TitleService:SetupTitles(player)
	local playerTitles = DataService:GetTable(player, "Titles")
	local TitlesFolder = player:FindFirstChild("PlayerTitles")

	if not TitlesFolder then
		TitlesFolder = Instance.new("Folder")
		TitlesFolder.Parent = player
		TitlesFolder.Name = "Titles"
	end

	local activeTitle = TitlesFolder:FindFirstChild("ActiveTitle")
	if not activeTitle then
		activeTitle = Instance.new("StringValue")
		activeTitle.Parent = TitlesFolder
		activeTitle.Name = "ActiveTitle"
	end
	activeTitle:SetAttribute("ID", playerTitles.ActiveTitle or "")
	activeTitle.Value = playerTitles.ActiveTitle or ""

	for titleID,titleInfo in pairs(playerTitles.Titles) do
		local titleData = TitleData.Titles[titleID]
		if not titleData then return end
		local value = TitlesFolder:FindFirstChild(titleID)
		if not value then
			value = Instance.new("StringValue")
			value.Name = titleID
			value.Parent = TitlesFolder
		end
		value:SetAttribute("Name", titleData.Name)
	end
end

function TitleService:GetTitle(player, titleID)
	local playerTitles = DataService:GetTable(player, "Titles")
	if playerTitles.Titles[titleID] then
		return
	end
	local titleData = TitleData.Titles[titleID]
	if titleData then
		playerTitles.Titles[titleID] = {}
	end
	
	local titlesFolder = player:WaitForChild("Titles")
	local value = titlesFolder:FindFirstChild(titleID)
	if not value then
		value = Instance.new("StringValue")
		value.Name = titleID
		value.Parent = titlesFolder
	end
	value:SetAttribute("Name", titleData.Name)

	NetworkingService:FireToClient(player, "PopUp", {
		["TitleData"] = titleData,
	})
	return true
end

function TitleService:EquipTitle(player, titleID)
	local playerTitles = DataService:GetTable(player, "Titles")
	if not playerTitles.Titles[titleID] then
		return
	end
	local titleData = TitleData.Titles[titleID]
	if not titleData then
		return
	end

	TitleService:UnEquipTitle(player)

	playerTitles.ActiveTitle = titleID
	local buffs = titleData.Buffs
	if buffs then
		GameEvents.AddBuff:Fire(player, titleData, titleID)
	end

	player.Titles.ActiveTitle:SetAttribute("ID", playerTitles.ActiveTitle or "")

end

function TitleService:UnEquipTitle(player)
	local playerTitles = DataService:GetTable(player, "Titles")
	if not playerTitles.ActiveTitle then
		return
	end
	local titleID = playerTitles.ActiveTitle
	local titleData = TitleData.Titles[titleID]
	if not titleData then
		return
	end
	local buffs = titleData.Buffs
	if buffs then
		GameEvents.RemoveBuff:Fire(player, titleData, titleID)
	end

	playerTitles.ActiveTitle = nil
	player.Titles.ActiveTitle:SetAttribute("ID", playerTitles.ActiveTitle or "")
end

return TitleService
