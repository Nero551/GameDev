local dataStoreService = game:GetService("DataStoreService")
local players = game:GetService("Players")

local store_Name = "PlayerData_V1"
local playerStore = dataStoreService:GetDataStore(store_Name)


local DataService = {}

DataService.PlayerDatas = {}

local function getDefaultData()

	local DefaultData = {
		Inventory = {
			["weapon_0000000001"] = {
				Name = "Fist",
				Amount = 1,
				Description = "Can't even hit your target barebones? noob.",
				Icon = "rbxassetid://2245735821",
				Rarity = "Rare",
				Type = "Melee"
			},
			["armor_0000000001"] = {
				Name = "Slime Head",
				Amount = 1,
				Description = "A friendly slime to keep you safe",
				Icon = "rbxassetid://70381584984142",
				Rarity = "Uncommon",
				Type = "Helmet",
			},

		},
		Equipped = {
			Melee = "weapon_0000000001",
			Sword = nil,
			RiftBorn = nil,
			Helmet =  nil,
			ChestPlate = nil,
			Leggings = nil,
			Boots = nil,
		},
		Stats = {
			Health         = { Base = 20,   FlatBuff = 1, FlatStatPoint = 0, Percent = 1, Final = 0 },

			Mana           = { Base = 20,   FlatBuff = 1, FlatStatPoint = 0, Percent = 1, Final = 0 }, 

			Melee          = { Base = 10 ,   FlatBuff = 1, FlatStatPoint = 0, Percent = 1, Final = 0 },

			Sword          = { Base = 10 , FlatBuff = 1, FlatStatPoint = 0, Percent = 1, Final = 0 },

			RiftBorn          = { Base = 10 , FlatBuff = 1, FlatStatPoint = 0, Percent = 1, Final = 0 },

			Defense        = { Base = 0 ,   FlatBuff = 1, FlatStatPoint = 0, Percent = 1, Final = 0 },

			CriticalDamage = { Base = 0 ,   FlatBuff = 0, FlatStatPoint = 0, Percent = 1, Final = 0 },

			CriticalRate   = { Base = 0 ,   FlatBuff = 0, FlatStatPoint = 0, Percent = 0, Final = 0 },
		},
		Mana = {
			MaxMana = 100,
			CurrentMana =  100,
			ManaRegen = 1,
		},
		Level = {
			CurrentLevel = 1,
			RequiredEXP = 100,
			CurrentEXP = 0 ,
			StatPoints = 0,
		},
		Currency = {
			Yen = 0,
			Fracta = 0,		
		},
		ItemPity = {},

		Quests = {
			ActiveQuests = {},
			CompletedQuests = {},
			TrackedQuest = nil,
		},
		Titles = {
			Titles = {},
			ActiveTitle = nil,

		},
		Buffs = {},
	}

	return  DefaultData
end	

local function deepCopy(tbl)
	if type(tbl) ~= "table" then return tbl end
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
	local defaultData = getDefaultData()

	for key, defaultValue in pairs(defaultData) do
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


function DataService:GetTable(player ,name)
	return DataService.PlayerDatas[player][name]
end
---LoadData---
function DataService:Load(player)
    local key = "Player_"..player.UserId

    local success, err = pcall(function()
        DataService.PlayerDatas[player] = playerStore:GetAsync(key)
    end)

    if not success or not DataService.PlayerDatas[player] then
        DataService.PlayerDatas[player] = getDefaultData()
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
			oldData = oldData or getDefaultData()
			return deepCopy(DataService.PlayerDatas[player])
		end)
	end)
	if not success then
		warn("Failed to save data for", player.Name, err)
	end
end


function DataService:Delete(player:Player)
	local key = "Player_"..player.UserId
	playerStore:RemoveAsync(key)
end

return DataService
