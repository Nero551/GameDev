local DataStoreService = game:GetService("DataStoreService")
local ServerScriptService = game:GetService("ServerScriptService")
local DefualtPlayerData = require(ServerScriptService.Modules.DefualtPlayerData)

local store_Name = "PlayerData_V1"
local playerStore = DataStoreService:GetDataStore(store_Name)

local DataService = {}

DataService.PlayerDatas = {}

local function deepCopy(tbl)
	if type(tbl) ~= "table" then
		return tbl
	end
	local copy = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local function ValidateData(playerData)
	for key, defaultValue in pairs(DefualtPlayerData) do
		if playerData[key] == nil then
			-- If missing, add the default
			playerData[key] = defaultValue
		elseif type(defaultValue) == "table" then
			-- If it’s a nested table, recursively validate
			for nestedKey, nestedValue in pairs(defaultValue) do
				if playerData[key][nestedKey] == nil then
					playerData[key][nestedKey] = nestedValue
				end
			end
		end
	end
	return playerData
end

function DataService:GetTable(player, name)
	if not player then
		warn("Player is nil", { debug.traceback() })
		return
	end
	if not DataService.PlayerDatas[player] then
		warn("Data Doesn't Exist For", player, { debug.traceback() })
		return
	end
	return DataService.PlayerDatas[player][name]
end
---LoadData---
function DataService:Load(player)
	local key = "Player_" .. player.UserId

	local success, err = pcall(function()
		DataService.PlayerDatas[player] = playerStore:GetAsync(key)
	end)

	if not success then
		warn("DataLoad Failed For", player.Name, ":", err)
	end
	if not success or not DataService.PlayerDatas[player] then
		DataService.PlayerDatas[player] = DefualtPlayerData
	end

	-- Validate the data
	DataService.PlayerDatas[player] = ValidateData(DataService.PlayerDatas[player])

	return DataService.PlayerDatas[player]
end

---SaveData---
function DataService:Save(player)
	local key = "Player_" .. player.UserId
	local success, err = pcall(function()
		playerStore:UpdateAsync(key, function(oldData)
			oldData = oldData or DefualtPlayerData
			return deepCopy(DataService.PlayerDatas[player])
		end)
	end)
	if not success then
		warn("Failed to save data for", player.Name, err)
		return
	end
	return
end

function DataService:Delete(player: Player)
	local key = "Player_" .. player.UserId
	playerStore:RemoveAsync(key)
end
return DataService
