local LevelService = require(script.Parent.LevelService)
local DataService = require(game.ServerScriptService.Services.Core.DataService)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

local StatService = {}

local function ApplyVitality(player: Player)
	local playerStats = DataService:GetTable(player, "Stats")
	local vitStat = playerStats.MainStats.Vitality
	local char = player.Character or player.CharacterAdded:Wait()

	local finalHealth = vitStat.Final
	local HEALTH_PER_POINT = 5
	local maxHealth = math.max(1, finalHealth * HEALTH_PER_POINT)

	VitalsService:ModifyVital(char, "Health", "ModifyMaxHealth", {
		["MaxHealth"] = maxHealth,
	})
end

local function ApplyIntelligence(player: Player)
	local playerStats = DataService:GetTable(player, "Stats")
	local char = player.Character or player.CharacterAdded:Wait()
	local intStat = playerStats.MainStats.Intelligence

	local finalMana = intStat.Final
	local MANA_PER_POINT = 5

	local maxMana = math.max(1, finalMana * MANA_PER_POINT)

	VitalsService:ModifyVital(char, "Mana", "ModifyMaxMana", {
		["MaxMana"] = maxMana,
	})
end

local function ApplyStrength(player: Player)
	local playerStats = DataService:GetTable(player, "Stats")
	local char = player.Character or player.CharacterAdded:Wait()
	local strengthStat = playerStats.MainStats.Strength

	local finalStrength = strengthStat.Final
	local Stamina_PER_POINT = 5

	local maxStamina = math.max(1, finalStrength * Stamina_PER_POINT)

	VitalsService:ModifyVital(char, "Stamina", "ModifyMaxStamina", {
		["MaxStamina"] = maxStamina,
	})
end

local function ApplyDexterity(player: Player)
	local playerStats = DataService:GetTable(player, "Stats")
	local dexStat = playerStats.MainStats.Dexterity

	playerStats.SubStats.CriticalChance.DexterityPercentBonus = dexStat.Final * 0.0002
	playerStats.SubStats.CriticalDamage.DexterityPercentBonus = dexStat.Final * 0.0002
end

---Setup Stats---
function StatService:SetupStats(player: Player)
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
		for statType, stat in pairs(table) do
			local statValue = folder:FindFirstChild(statType)
			if not statValue then
				statValue = Instance.new("StringValue")
				statValue.Name = statType
				statValue.Parent = folder
				for valueType, value in pairs(stat) do
					statValue:SetAttribute(valueType, value)
				end
			end
		end
	end
	StatService:UpdateStats(player)
end

function StatService:GetStat(player: Player, stat)
	local playerStats = DataService:GetTable(player, "Stats")
	for _, table in pairs(playerStats) do
		if table[stat] then
			return table[stat]
		end
	end
	return
end

---Update Stats---
function StatService:UpdateStats(player: Player)
	local playerStats = DataService:GetTable(player, "Stats")

	for catagory, stats in pairs(playerStats) do
		for statType, statTable in pairs(stats) do
			local statValue = player:WaitForChild("Stats"):WaitForChild(catagory):WaitForChild(statType)
			statTable.Final = 0
			local percentTotal = 0

			for boost, val in pairs(statTable) do
				if boost ~= "Final" then
					if string.find(boost, "Percent") then
						percentTotal += val or 0
					else
						statTable.Final += val or 0
					end

					statValue:SetAttribute(boost, val)
				end
			end
			statTable.Final *= (1 + percentTotal)

			statValue:SetAttribute("Final", statTable.Final)
		end
	end
	ApplyVitality(player)
	ApplyIntelligence(player)
	ApplyStrength(player)
	ApplyDexterity(player)
end

---Allocate Statpoint---
function StatService:AllocateStatPoint(player, statType, amount)
	local playerLevel = DataService:GetTable(player, "Level")
	local playerStats = DataService:GetTable(player, "Stats")

	if playerLevel.StatPoints <= 0 then
		return
	end

	if amount > playerLevel.StatPoints then
		amount = playerLevel.StatPoints
	end
	playerLevel.StatPoints -= amount
	playerStats.MainStats[statType].FlatStatPoint += amount
	player:WaitForChild("Level"):FindFirstChild("StatPoints"):SetAttribute("Amount", playerLevel.StatPoints)
	StatService:UpdateStats(player)
	LevelService:IncreaseEXP(player, 0)
end

---Reset Stats---
function StatService:ResetStats(player: Player)
	local playerLevel = DataService:GetTable(player, "Level")
	local playerStats = DataService:GetTable(player, "Stats")

	playerLevel.StatPoints = (playerLevel.CurrentLevel - 1) * 4
	for _, stat in pairs(playerStats.MainStats) do
		stat.FlatStatPoint = 0
	end
	StatService:UpdateStats(player)
	LevelService:IncreaseEXP(player, 0)
end

---Apply Item Buffs---
function StatService:ApplyBuffs(player: Player, buffs)
	if not buffs then
		return
	end
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
function StatService:ResetBuffs(player: Player)
	local playerStats = DataService:GetTable(player, "Stats")
	for _, table in pairs(playerStats) do
		for _, stat in pairs(table) do
			stat.FlatBuff = 0
			stat.Percent = 0
		end
	end
	StatService:UpdateStats(player)
end
return StatService
