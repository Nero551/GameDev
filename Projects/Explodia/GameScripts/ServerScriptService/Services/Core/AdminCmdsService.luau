local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TechniqueService = require(ServerScriptService.Services.Combat.TechniqueService)
local TechniqueData = require(ReplicatedStorage.Modules.Data.TechniqueData)
local StringHelper = require(ReplicatedStorage.Modules.Helpers.StringHelper)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local TitleData = require(game.ReplicatedStorage.Modules.Data.TitleData)
local DataService = require(game.ServerScriptService.Services.Core.DataService)
local InventoryService = require(game.ServerScriptService.Services.Profile.InventoryService)
local TitleService = require(game.ServerScriptService.Services.Profile.TitleService)
local LevelService = require(game.ServerScriptService.Services.Profile.LevelService)
local StateService = require(game.ServerScriptService.Services.Core.StateService)



local function FindPlayerByPartialName(text)
	if text == nil then
		return
	end
	for _, player in ipairs(game.Players:GetPlayers()) do
		if string.sub(string.lower(player.Name), 1, #text) == string.lower(text) then
			return player
		end
	end
	return
end

local AdminCmdsService = {}

function AdminCmdsService:SelectCommand(player, msg)
	local ADMIN_IDS = require(game.ReplicatedStorage.Modules.Data.AdminIDs)
	if not ADMIN_IDS[player.UserId] then
		return
	end
	local msgParts = msg:split(" ")

	if msgParts[1] == "/deletedata" then
		AdminCmdsService:DeleteData(msgParts)
	end

	if msgParts[1] == "/printdata" then
		AdminCmdsService:PrintData(msgParts)
	end

	if msgParts[1] == "/exp" then
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

	if msgParts[1] == "/obtain" then
		AdminCmdsService:ObtainTechnique(msgParts)
	end
end

function AdminCmdsService:ObtainTechnique(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])

	local techniqueNameParts = {}
	local itemPartsEnd = #msgParts

	for i = 3, itemPartsEnd do
		table.insert(techniqueNameParts, msgParts[i])
	end

	local techniqueName = table.concat(techniqueNameParts, " ")
	techniqueName = StringHelper:CapitalizeFirstLetters(techniqueName)
	local techniqueID = TechniqueData:GetTechniqueID(techniqueName)
	if not playerWanted or not techniqueID then
		return
	end
	TechniqueService:ObtainTechnique(playerWanted, techniqueID)
end

function AdminCmdsService:DeleteData(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])
	if not playerWanted then
		return
	end
	DataService:Delete(playerWanted)
	DataService.PlayerDatas[playerWanted] = nil
	playerWanted:Kick("Your data has been deleted. Rejoin.")
end

function AdminCmdsService:PrintData(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])
	if not playerWanted then
		return
	end
	print(DataService.PlayerDatas[playerWanted])
end

function AdminCmdsService:GainEXP(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])
	local amount = tonumber(msgParts[#msgParts])
	if not playerWanted or not amount then
		return
	end
	LevelService:IncreaseEXP(playerWanted, amount)
end

function AdminCmdsService:GiveItem(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])
	local itemNameParts = {}
	local amount = tonumber(msgParts[#msgParts]) or 1
	local itemPartsEnd = #msgParts - 1
	if amount ~= tonumber(msgParts[#msgParts]) then
		itemPartsEnd = #msgParts
	end

	if not playerWanted or not amount then
		return
	end

	for i = 3, itemPartsEnd do
		table.insert(itemNameParts, msgParts[i])
	end
	local itemName = table.concat(itemNameParts, " ")
	itemName = StringHelper:CapitalizeFirstLetters(itemName)
	local itemData, itemID = ItemDataBase:GetItemData(itemName)
	if not itemData or not itemID then
		warn("Couldn't Find " .. itemName)
		return
	end
	local success = InventoryService:AddItem(itemID, amount, playerWanted)
	if not success then
		warn("Failed to add: " .. itemName)
	end
end

function AdminCmdsService:RemoveItem(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])
	local itemNameParts = {}
	local amount = tonumber(msgParts[#msgParts]) or 1

	if not playerWanted or not amount then
		return
	end

	local itemPartsEnd = #msgParts - 1
	if amount ~= tonumber(msgParts[#msgParts]) then
		itemPartsEnd = #msgParts
	end
	for i = 3, itemPartsEnd do
		table.insert(itemNameParts, msgParts[i])
	end
	local itemName = table.concat(itemNameParts, " ")
	itemName = StringHelper:CapitalizeFirstLetters(itemName)
	local itemData, itemID = ItemDataBase:GetItemData(itemName)
	if not itemData or not itemID then
		warn("Couldn't Find " .. itemName)
		return
	end
	local success = InventoryService:RemoveItem(itemID, amount, playerWanted)
	if not success then
		warn("Failed to Remove: " .. itemName)
	end
end

function AdminCmdsService:GetTitle(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])
	if not playerWanted then
		return
	end
	local itemNameParts = {}
	local itemPartsEnd = #msgParts

	for i = 3, itemPartsEnd do
		table.insert(itemNameParts, msgParts[i])
		print(msgParts[i])
	end
	local titleName = table.concat(itemNameParts, " ")
	titleName = StringHelper:CapitalizeFirstLetters(titleName)
	local titleID = TitleData:GetTitleID(titleName)
	if not titleID then
		warn("Couldn't Find " .. titleName)
		return
	end
	local titles = DataService:GetTable(playerWanted, "Titles")
	if titles then
		local success = TitleService:GetTitle(playerWanted, titleID)
		if success then
		else
			warn("Failed to add: " .. titleName)
		end
	end
end

function AdminCmdsService:ApplyState(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])

	local char = playerWanted.Character or playerWanted.CharacterAdded:Wait()

	local state = msgParts[3]
	local duration = tonumber(msgParts[#msgParts])

	if not playerWanted then
		return
	end
	if not state then
		return
	end
	if not duration then
		return
	end
	StateService:AddState(char, StringHelper:CapitalizeFirstLetters(state), duration)
end

return AdminCmdsService
