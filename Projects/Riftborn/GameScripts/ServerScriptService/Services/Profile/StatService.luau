local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)

local GameEvents = require(game.ReplicatedStorage.Modules.Core.GameEvents)
local DataService = require(game.ServerScriptService.Services.Profile.DataService)
local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)


local StatService = {}

local function ApplyHealth(player:Player)
	local playerStats = DataService:GetTable(player, "Stats")
	local playerHealthStats = playerStats.MainStats.Health
	local char = player.Character or player.CharacterAdded:Wait()

	local finalHealth = playerHealthStats.Final
	local HEALTH_PER_POINT = 5
	local MIN_HEALTH = playerHealthStats.Base * HEALTH_PER_POINT

	local maxHealth = math.max(MIN_HEALTH, finalHealth * HEALTH_PER_POINT)
	
	CharacterVitalsService:ModifyVital(char, "Health" ,"ModifyMaxHealth", {
		["MaxHealth"] = maxHealth	
	})
	
end

local function ApplyMana(player:Player)
	local playerStats = DataService:GetTable(player,"Stats")
	local char = player.Character or player.CharacterAdded:Wait()
	local playerManaStats = playerStats.MainStats.Mana
	
	local finalMana = playerManaStats.Final
	local MANA_PER_POINT = 5
	local MIN_MANA = playerManaStats.Base * MANA_PER_POINT

	local maxMana = math.max(MIN_MANA,finalMana * MANA_PER_POINT)

	CharacterVitalsService:ModifyVital(char, "Mana", "ModifyMaxMana", {
		["MaxMana"] = maxMana,
	})
	
end



---Setup Stats---
function StatService:SetupStats(player:Player)
	local playerStats = DataService:GetTable(player, "Stats")
	
	local statsFolder = player:FindFirstChild("Stats")
	
	if not statsFolder then
		statsFolder = Instance.new("Folder")
		statsFolder.Name = "Stats"
		statsFolder.Parent = player
	end

	for type, table in pairs(playerStats) do
		local folder = statsFolder:FindFirstChild(type)
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = type
			folder.Parent = statsFolder
		end
		for statType,stat in pairs(table) do
			local statFolder = folder:FindFirstChild(statType)
			if not statFolder then
				statFolder = Instance.new("Folder")
				statFolder.Name = statType
				statFolder.Parent = folder
				for valueType,value in pairs(stat) do
					local valueInstance = statFolder:FindFirstChild(valueType) 
					if not valueInstance then
						valueInstance = Instance.new("IntValue")
						valueInstance.Name = valueType
						valueInstance.Value = value
						valueInstance.Parent = statFolder
					end
				end
			end
		end
	end
	StatService:UpdateStats(player)
end

function StatService:GetStat(player:Player, stat)
	local playerStats = DataService:GetTable(player, "Stats")
	for type,table in pairs(playerStats) do
		if table[stat] then
			return table[stat]
		end
	end
	return
end

---Update Stats---
function StatService:UpdateStats(player:Player)
	local playerStats = DataService:GetTable(player, "Stats")
	for type, table in pairs(playerStats) do
		for statType,stat in pairs(table) do
			stat.FlatStatPoint = math.clamp(stat.FlatStatPoint, 0, 3000)
			stat.Final = (stat.Base + stat.FlatStatPoint + stat.FlatBuff) * (1 + stat.Percent)
			local statFolder = player:WaitForChild("Stats"):WaitForChild(type):WaitForChild(statType)
			statFolder.Base.Value = stat.Base
			statFolder.Percent.Value = stat.Percent
			statFolder.FlatBuff.Value = stat.FlatBuff
			statFolder.FlatStatPoint.Value = stat.FlatStatPoint
			statFolder.Final.Value = stat.Final
		end	
	end
	ApplyHealth(player)
	ApplyMana(player)
	GameEvents.UpdateMana:Fire(player)
end

---Allocate Statpoint---
function StatService:AllocateStatPoint(player:Player, statType, amount)
	local playerLevel = DataService:GetTable(player, "Level")
	local playerStats = DataService:GetTable(player, "Stats")
	
	if 	playerLevel.StatPoints <= 0 or playerStats.MainStats[statType].FlatStatPoint  >= 3000  then return end
	if playerStats.MainStats[statType].FlatStatPoint + amount > 3000 then
		amount = 3000 - playerStats.MainStats[statType].FlatStatPoint
	end
	if amount > playerLevel.StatPoints then
		amount = playerLevel.StatPoints

	end
	playerLevel.StatPoints -= amount
	playerStats.MainStats[statType].FlatStatPoint += amount
	StatService:UpdateStats(player)
	NetworkingService:FireToClient(player , "UpdateEXP", playerLevel)
end


---Reset Stats---
function StatService:ResetStats(player:Player)
	local playerLevel = DataService:GetTable(player, "Level")
	local playerStats = DataService:GetTable(player, "Stats")
	
	playerLevel.StatPoints = (playerLevel.CurrentLevel - 1) * 4
	playerStats.MainStats.Health.FlatStatPoint = 0 
	playerStats.MainStats.Sword.FlatStatPoint = 0 
	playerStats.MainStats.Melee.FlatStatPoint = 0 
	playerStats.MainStats.Mana.FlatStatPoint = 0
	playerStats.MainStats.RiftBorn.FlatStatPoint = 0
	StatService:UpdateStats(player)
	NetworkingService:FireToClient(player , "UpdateEXP", playerLevel)
end

---Apply Item Buffs---
function StatService:ApplyBuffs(player:Player,  buffs)
	if not buffs then return end
	local playerStats = DataService:GetTable(player, "Stats")
	
	for statType, buff in pairs(buffs) do
		local stat = playerStats.MainStats[statType] or playerStats.SideStats[statType]
		if stat then
			if buff.Flat then
				stat.FlatBuff += buff.Flat
			end
			if buff.Percent then
				stat.Percent += buff.Percent
			end
		end
	end
	StatService:UpdateStats(player)
end

---Reset Buffs---
function StatService:ResetBuffs(player:Player)
	local playerStats = DataService:GetTable(player, "Stats")
	for type, table in pairs(playerStats) do
		for statType, stat in pairs(table) do
			stat.FlatBuff = 0
			stat.Percent = 0
		end
	end
	StatService:UpdateStats(player)
end
return StatService
