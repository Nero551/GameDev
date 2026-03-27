local DataService = require(game.ServerScriptService.Services.Core.DataService)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

local StatService = {}

local function ApplyHealth(player: Player)
	local playerStats = DataService:GetTable(player, "Stats")
	local vitStat = playerStats.MainStats.Vitality
	local char = player.Character or player.CharacterAdded:Wait()

	local finalHealth = vitStat.Final
	local HEALTH_PER_POINT = 5
	local MIN_HEALTH = vitStat.Base * HEALTH_PER_POINT

	local maxHealth = math.max(MIN_HEALTH, finalHealth * HEALTH_PER_POINT)

	VitalsService:ModifyVital(char, "Health", "ModifyMaxHealth", {
		["MaxHealth"] = maxHealth,
	})
end

local function ApplyMana(player: Player)
	local playerStats = DataService:GetTable(player, "Stats")
	local char = player.Character or player.CharacterAdded:Wait()
	local intStat = playerStats.MainStats.Intelligence

	local finalMana = intStat.Final
	local MANA_PER_POINT = 5
	local MIN_MANA = intStat.Base * MANA_PER_POINT

	local maxMana = math.max(MIN_MANA, finalMana * MANA_PER_POINT)

	VitalsService:ModifyVital(char, "Mana", "ModifyMaxMana", {
		["MaxMana"] = maxMana,
	})
end

local function ApplyStamina(player: Player)
	local playerStats = DataService:GetTable(player, "Stats")
	local char = player.Character or player.CharacterAdded:Wait()
	local agilityStat = playerStats.MainStats.Agility

	local finalStamina = agilityStat.Final
	local Stamina_PER_POINT = 5
	local MIN_STAMINA = agilityStat.Base * Stamina_PER_POINT

	local maxStamina = math.max(MIN_STAMINA, finalStamina * Stamina_PER_POINT)

	VitalsService:ModifyVital(char, "Stamina", "ModifyMaxStamina", {
		["MaxStamina"] = maxStamina,
	})
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
	for catagory, t in pairs(playerStats) do
		for statType, statTable in pairs(t) do
			statTable.Final = (statTable.Base + statTable.FlatStatPoint + statTable.FlatBuff) * (1 + statTable.Percent)
			local statValue = player:WaitForChild("Stats"):WaitForChild(catagory):WaitForChild(statType)
			for type, value in pairs(statTable) do
				statValue:SetAttribute(type, value)
			end
		end
	end
	ApplyHealth(player)
	ApplyMana(player)
	ApplyStamina(player)
end

---Allocate Statpoint---
function StatService:AllocateStatPoint(player, statType, amount)
	local playerLevel = DataService:GetTable(player, "Level")
	local playerStats = DataService:GetTable(player, "Stats")

	if playerLevel.StatPoints <= 0  then
		return
	end
	
	if amount > playerLevel.StatPoints then
		amount = playerLevel.StatPoints
	end
	playerLevel.StatPoints -= amount
	playerStats.MainStats[statType].FlatStatPoint += amount
	player:WaitForChild("Level"):FindFirstChild("StatPoints"):SetAttribute("Amount", playerLevel.StatPoints)
	StatService:UpdateStats(player)
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
