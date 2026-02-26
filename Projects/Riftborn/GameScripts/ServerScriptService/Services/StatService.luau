local repstor = game:GetService("ReplicatedStorage")
local remotes = repstor.Remotes

local GameEvents = require(game.ReplicatedStorage.Modules.GameEvents)
local DataService = require(script.Parent.Parent.Services.DataService)
local CharacterVitalsService = require(script.Parent.Parent.Services.CharacterVitalsService)


local StatService = {}


---Create StatsFolder---
local function CreateStatsFolder(parent , name , base)
	
	local folder = parent:FindFirstChild(name)
	
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent

		local baseVal = Instance.new("NumberValue")
		baseVal.Name = "Base"
		baseVal.Value = base
		baseVal.Parent = folder

		local flatStatPointVal = Instance.new("NumberValue")
		flatStatPointVal.Name = "FlatStatPoint"
		flatStatPointVal.Value = 0
		flatStatPointVal.Parent = folder

		local flatBuffVal = Instance.new("NumberValue")
		flatBuffVal.Name = "FlatBuff"
		flatBuffVal.Value = 0
		flatBuffVal.Parent = folder

		local percentVal = Instance.new("NumberValue")
		percentVal.Name = "Percent"
		percentVal.Value = 0 -- 0.1 = 10%
		percentVal.Parent = folder

		local finalVal = Instance.new("NumberValue")
		finalVal.Name = "Final"
		finalVal.Value = baseVal.Value + flatStatPointVal.Value + flatBuffVal.Value * (percentVal.Value + 1)
		finalVal.Parent = folder
	end
	
	
end


local function ApplyHealth(player:Player)
	local playerStats = DataService:GetTable(player, "Stats")
	local playerHealthStats = playerStats.Health
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
	local playerManaStats = playerStats.Mana
	
	local finalMana = playerManaStats.Final
	local MANA_PER_POINT = 5
	local MIN_MANA = playerManaStats.Base * MANA_PER_POINT

	local maxMana = math.max(MIN_MANA,finalMana * MANA_PER_POINT)

	CharacterVitalsService:ModifyVital(char, "Mana", "ModifyMaxMana", {
		["MaxMana"] = maxMana,
	})
	
end

---Calculate Final Stat---
local function CalculateFinal(stat)
	local percent = math.clamp(stat.Percent, -0.9, 10)
	return (stat.Base + stat.FlatStatPoint + stat.FlatBuff) * (1 + percent)
end


---Setup Stats---
function StatService:SetupStats(player:Player)
	local playerStats = DataService:GetTable(player, "Stats")
	
	local statsFolder = player:FindFirstChild("PlayerStats")
	
	if not statsFolder then
		statsFolder = Instance.new("Folder")
		statsFolder.Name = "PlayerStats"
		statsFolder.Parent = player
	end

	for statType, stat in pairs(playerStats) do
		CreateStatsFolder(statsFolder, statType, stat.Base)
		
		stat.Final = CalculateFinal(stat)
	end
	StatService:UpdateStats(player)
	ApplyHealth(player)
	ApplyMana(player)
end

---Update Stats---
function StatService:UpdateStats(player:Player)
	local playerStats = DataService:GetTable(player, "Stats")
	for statType, stat in pairs(playerStats) do
		stat.FlatStatPoint = math.clamp(stat.FlatStatPoint, 0 , 3000) 
		stat.Final = CalculateFinal(stat)
		local statFolder = player:WaitForChild("PlayerStats"):WaitForChild(statType)
		statFolder.Base.Value = stat.Base
		statFolder.Percent.Value = stat.Percent
		statFolder.FlatBuff.Value = stat.FlatBuff
		statFolder.FlatStatPoint.Value = stat.FlatStatPoint
		statFolder.Final.Value = stat.Final
	end
	ApplyHealth(player)
	ApplyMana(player)
	GameEvents.UpdateMana:Fire(player)
end

---Allocate Statpoint---
function StatService:AllocateStatPoint(player:Player, statType, amount)
	local playerLevel = DataService:GetTable(player, "Level")
	local playerStats = DataService:GetTable(player, "Stats")

	print(playerLevel.StatPoints, playerStats[statType])
	
	if 	playerLevel.StatPoints <= 0 or playerStats[statType].FlatStatPoint  >= 3000  then return end
	if playerStats[statType].FlatStatPoint + amount > 3000 then
		amount = 3000 - playerStats[statType].FlatStatPoint
	end
	if amount > playerLevel.StatPoints then
		amount = playerLevel.StatPoints

	end
	playerLevel.StatPoints -= amount
	playerStats[statType].FlatStatPoint = playerStats[statType].FlatStatPoint + amount
	StatService:UpdateStats(player)
	remotes.UpdateEXP:FireClient(player ,playerLevel)
end


---Reset Stats---
function StatService:ResetStats(player:Player)
	local playerLevel = DataService:GetTable(player, "Level")
	local playerStats = DataService:GetTable(player, "Stats")
	
	playerLevel.StatPoints = (playerLevel.CurrentLevel - 1) * 4
	playerStats.Health.FlatStatPoint = 0 
	playerStats.Sword.FlatStatPoint = 0 
	playerStats.Melee.FlatStatPoint = 0 
	playerStats.Mana.FlatStatPoint = 0
	playerStats.RiftBorn.FlatStatPoint = 0
	StatService:UpdateStats(player)
	remotes.UpdateEXP:FireClient(player ,playerLevel)
end

---Apply Item Buffs---
function StatService:ApplyBuffs(player:Player,  buffs)
	if not buffs then return end
	local playerStats = DataService:GetTable(player, "Stats")
	
	for statType, buff in pairs(buffs) do
		local stat = playerStats[statType]
		if stat then
			if buff.Flat then
				stat.FlatBuff += buff.Flat
			end
			if buff.Percent then
				stat.Percent += buff.Percent
			end
		end
	end
	self:UpdateStats(player)
end

---Reset Buffs---
function StatService:ResetBuffs(player:Player)
	local playerStats = DataService:GetTable(player, "Stats")
	for statType, stat in pairs(playerStats) do
		stat.FlatBuff = 0
		stat.Percent = 0
	end
end
return StatService
