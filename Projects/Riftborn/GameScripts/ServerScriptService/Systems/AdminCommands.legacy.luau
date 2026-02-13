local players = game:GetService("Players")
local repstor = game:GetService("ReplicatedStorage")
local modules =  repstor.Modules
local remotes = repstor.Remotes
local itemDataBase = require(modules.Data.ItemDataBase)
local titleData = require(modules.Data.TitleData)
local DataService = require(script.Parent.Parent.Services.DataService)
local InventoryService = require(script.Parent.Parent.Services.InventoryService)
local TitleService = require(script.Parent.Parent.Services.TitleService)
local LevelService = require(script.Parent.Parent.Services.LevelService)

local function CapitalizeWords(str)
	return (str:gsub("(%a)([%w_']*)", function(first, rest)
		return first:upper()..rest:lower()
	end))
end

---ADMINS---
local ADMIN_IDS = {
	[1561036823] = true,
	
}

---COMMANDS---
players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		if not ADMIN_IDS[player.UserId] then return end
		local msgParts = msg:split(" ")
		
		
		---DELTE DATA COMMAND---
		if msgParts[1] == "/deletedata" then
			local playerWanted = game:GetService("Players"):FindFirstChild(msgParts[2])
			if not playerWanted then return end
			DataService:Delete(playerWanted)
			DataService.PlayerDatas[player] = nil
			playerWanted:Kick("Your data has been deleted. Rejoin.")
		end
		
		
		---PRINT DATA COMMAND---
		if msgParts[1] == "/printdata" then
			--local playerWanted = game:GetService("Players"):FindFirstChild(msgParts[2])
			--if not playerWanted then return end
			print(DataService.PlayerDatas[player])
		end
		
		---Give EXP---
		if msgParts[1] == "/exp"  then
		--	local playerWanted = game:GetService("Players"):FindFirstChild(msgParts[2])
			--if not playerWanted then return end
			local amount =  tonumber(msgParts[#msgParts])
			LevelService:IncreaseEXP(player, amount)
			
		end
		
		---GIVE ITEM COMMAND---
		if msgParts[1] == "/give" then
			local itemNameParts = {}
			local lastIndex = #msgParts
			local amount = tonumber(msgParts[#msgParts])  or 1
			local itemPartStart = #msgParts - 1
			if amount ~= tonumber(msgParts[#msgParts]) then
				itemPartStart = #msgParts
			end
			for i = 2, itemPartStart do
				table.insert(itemNameParts, msgParts[i])
			end
			local itemName = table.concat(itemNameParts, " ")
			itemName = CapitalizeWords(itemName)
			local itemType
			local  itemData,itemID = itemDataBase:GetItemData(itemName)
			if not itemData or not itemID then
				print(itemData, itemID)
				warn("Couldn't Find "..itemName)
				return
			end
			local success = InventoryService:AddItem(itemID, amount, player)
			if not success then
				warn("Failed to add: "..itemName)
			end
		end
		
		---REMOVE ITEM COMMAND---
		if msgParts[1] == "/remove" then
			local itemNameParts = {}
			local lastIndex = #msgParts
			local amount = tonumber(msgParts[#msgParts])  or 1
			local itemPartStart = #msgParts - 1
			if amount ~= tonumber(msgParts[#msgParts]) then
				itemPartStart = #msgParts
			end
			for i = 2, itemPartStart do
				table.insert(itemNameParts, msgParts[i])
			end
			print(table.concat(itemNameParts, " "))
			local itemName = table.concat(itemNameParts, " ")
			itemName = CapitalizeWords(itemName)
			print(itemName)
			local itemType
			local  itemData,itemID = itemDataBase:GetItemData(itemName)
			if itemData and itemID then
				warn("Couldn't Find "..itemName.."Data")
				return
			end
			local success = InventoryService:RemoveItem(itemID, amount)
			if not success then
				warn("Failed to Remove: "..itemName)
			end
		end
		
		---GIVE Title COMMAND---
		if msgParts[1] == "/get" then
			local itemNameParts = {}
			local lastIndex = #msgParts
			local amount = tonumber(msgParts[#msgParts])  or 1
			local itemPartStart = #msgParts - 1
			if amount ~= tonumber(msgParts[#msgParts]) then
				itemPartStart = #msgParts
			end
			for i = 2, itemPartStart do
				table.insert(itemNameParts, msgParts[i])
			end
			local titleName = table.concat(itemNameParts, " ")
			titleName = CapitalizeWords(titleName)
			local itemType
			local  titleID = titleData:GetTitleID(titleName)
			if not titleID then
				warn("Couldn't Find "..titleName)
				return
			end
			local titles = DataService:GetTable(player,"Titles")
			if titles then
				local success = TitleService:GetTitle(player, titleID)
				if success then
					
				else
					warn("Failed to add: "..titleName)
				end
			end
		end
	end)
end)
