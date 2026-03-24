local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local DataService = require(game.ServerScriptService.Services.Core.DataService)

local LevelService = {}

function LevelService:SetupLevel(player)
	local playerLevel = DataService:GetTable(player, "Level")
	local LevelFolder = player:FindFirstChild("Level")

	if not LevelFolder then
		LevelFolder = Instance.new("Folder")
		LevelFolder.Parent = player
		LevelFolder.Name = "Level"
		LevelService:IncreaseEXP(player, 0)
	end

	for stat, v in pairs(playerLevel) do
		local value = LevelFolder:FindFirstChild(stat)
		if not value then
			value = Instance.new("StringValue")
			value.Name = stat
			value.Parent = LevelFolder
		end
		value:SetAttribute("Amount", v)
	end
end

function LevelService:IncreaseEXP(player, EXP)
	local playerLevel = DataService:GetTable(player, "Level")
	local LevelFolder = player:WaitForChild("Level")
	playerLevel.CurrentEXP += EXP

	local maxLevel = 3000

	task.spawn(function()
		while playerLevel.CurrentEXP >= playerLevel.RequiredEXP do
			if playerLevel.CurrentLevel >= maxLevel then
				playerLevel.CurrentLevel = maxLevel
				playerLevel.RequiredEXP = math.floor(100 * (maxLevel ^ 1.9))
				playerLevel.CurrentEXP = playerLevel.RequiredEXP
				return
			end

			playerLevel.CurrentLevel += 1
			playerLevel.CurrentEXP -= playerLevel.RequiredEXP

			playerLevel.RequiredEXP = math.floor(100 * (playerLevel.CurrentLevel ^ 1.9))
			playerLevel.StatPoints += 4
			NetworkingService:FireToClient(player, "PopUp", {
				["Level"] = playerLevel.CurrentLevel,
			})
			for stat, v in pairs(playerLevel) do
				local value = LevelFolder:FindFirstChild(stat)
				if not value then
					value = Instance.new("StringValue")
					value.Name = stat
					value.Parent = LevelFolder
				end
				value:SetAttribute("Amount", v)
			end
			task.wait(0.1)
		end
	end)
	for stat, v in pairs(playerLevel) do
		local value = LevelFolder:FindFirstChild(stat)
		if not value then
			value = Instance.new("StringValue")
			value.Name = stat
			value.Parent = LevelFolder
		end
		value:SetAttribute("Amount", v)
	end

	if EXP > 0 then
		NetworkingService:FireToClient(player, "PopUp", {
			["EXP"] = EXP,
		})
	end
end

return LevelService
