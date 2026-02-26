local repstor = game:GetService("ReplicatedStorage")
local modules =  repstor.Modules
local itemDataBase = require(modules.Data.ItemDataBase)
local titleData = require(modules.Data.TitleData)
local DataService = require(script.Parent.Parent.Services.DataService)
local InventoryService = require(script.Parent.Parent.Services.InventoryService)
local TitleService = require(script.Parent.Parent.Services.TitleService)
local LevelService = require(script.Parent.Parent.Services.LevelService)
local stateService = require(modules.StateService)

local function CapitalizeWords(str)
	return (str:gsub("(%a)([%w_']*)", function(first, rest)
		return first:upper()..rest:lower()
	end))
end

local function FindPlayerByPartialName(text)
	if text == nil then return end
	for _, player in ipairs(game.Players:GetPlayers()) do
		if string.sub(string.lower(player.Name), 1, #text) == string.lower(text) then
			return player
		end
	end
	return
end

local AdminCmdsService = {}

function AdminCmdsService:DeleteData(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])
	if not playerWanted then return end
	DataService:Delete(playerWanted)
	DataService.PlayerDatas[playerWanted] = nil
	playerWanted:Kick("Your data has been deleted. Rejoin.")
end

function AdminCmdsService:PrintData(msgParts)
	local playerWanted =FindPlayerByPartialName(msgParts[2])
	if not playerWanted then return end
	print(DataService.PlayerDatas[playerWanted])
end

function AdminCmdsService:GainEXP(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])
	local amount =  tonumber(msgParts[#msgParts])
	if not playerWanted or not amount then return end
	LevelService:IncreaseEXP(playerWanted, amount)
end

function AdminCmdsService:GiveItem(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])
	local itemNameParts = {}
	local amount = tonumber(msgParts[#msgParts])  or 1
	local itemPartsEnd = #msgParts - 1
	if amount ~= tonumber(msgParts[#msgParts]) then
		itemPartsEnd = #msgParts
	end
	
	if not playerWanted or not amount then return end
	
	for i = 3, itemPartsEnd do
		table.insert(itemNameParts, msgParts[i])
	end
	local itemName = table.concat(itemNameParts, " ")
	itemName = CapitalizeWords(itemName)
	local  itemData,itemID = itemDataBase:GetItemData(itemName)
	if not itemData or not itemID then
		warn("Couldn't Find "..itemName)
		return
	end
	local success = InventoryService:AddItem(itemID, amount, playerWanted)
	if not success then
		warn("Failed to add: "..itemName)
	end
end

function AdminCmdsService:RemoveItem(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])
	local itemNameParts = {}
	local amount = tonumber(msgParts[#msgParts])  or 1
	
	if not playerWanted or not amount then return end
	
	local itemPartsEnd = #msgParts - 1
	if amount ~= tonumber(msgParts[#msgParts]) then
		itemPartsEnd = #msgParts
	end
	for i = 3, itemPartsEnd do
		table.insert(itemNameParts, msgParts[i])
	end
	print(table.concat(itemNameParts, " "))
	local itemName = table.concat(itemNameParts, " ")
	itemName = CapitalizeWords(itemName)
	print(itemName)
	local  itemData,itemID = itemDataBase:GetItemData(itemName)
	if not itemData or not itemID then
		warn("Couldn't Find "..itemName)
		return
	end
	local success = InventoryService:RemoveItem(itemID, amount, playerWanted)
	if not success then
		warn("Failed to Remove: "..itemName)
	end
end

function AdminCmdsService:GetTitle(msgParts)
	
	local playerWanted = FindPlayerByPartialName(msgParts[2])
	if not playerWanted  then return end
	local itemNameParts = {}
	local itemPartsEnd = #msgParts

	for i = 3, itemPartsEnd do
		table.insert(itemNameParts, msgParts[i])
		print(msgParts[i])
	end
	local titleName = table.concat(itemNameParts, " ")
	titleName = CapitalizeWords(titleName)
	local  titleID = titleData:GetTitleID(titleName)
	if not titleID then
		warn("Couldn't Find "..titleName)
		return
	end
	local titles = DataService:GetTable(playerWanted,"Titles")
	if titles then
		local success = TitleService:GetTitle(playerWanted, titleID)
		if success then

		else
			warn("Failed to add: "..titleName)
		end
	end
end

function AdminCmdsService:ApplyState(msgParts)
	local playerWanted = FindPlayerByPartialName(msgParts[2])

	local char = playerWanted.Character or playerWanted.CharacterAdded:Wait()
	
	local state = msgParts[3]
	local duration = tonumber(msgParts[#msgParts])
	
	if not playerWanted then return end
	if not state then return end
	if not duration then return end
	stateService.addState(char, CapitalizeWords(state), duration)
end

return AdminCmdsService
