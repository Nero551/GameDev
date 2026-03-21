local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local NetworkingService = ModuleLoader:Load("Shared", "NetworkingService")
local DataService = ModuleLoader:Load("Server", "DataService")


local LevelService = {}

function LevelService:SetupLevel(player)
	local playerLevel = DataService:GetTable(player, "Level")
	local LevelFolder = player:FindFirstChild("PlayerLevel")
	
	if not LevelFolder then
		LevelFolder = Instance.new("Folder")
		LevelFolder.Parent = player
		LevelFolder.Name = "PlayerLevel"
	end	

	for stat,v in pairs(playerLevel) do
		local value = LevelFolder:FindFirstChild(stat)
		if not value then
			value = Instance.new("StringValue")
			value.Name = stat
			value.Parent = LevelFolder
		end
		value:SetAttribute("Amount", v)
	end
end

function LevelService:IncreaseEXP(player , EXP)
	local playerLevel = DataService:GetTable(player , "Level")
	local LevelFolder = player:WaitForChild("PlayerLevel")
	playerLevel.CurrentEXP  += EXP
	
	local maxLevel = 3000
	
	task.spawn(function()
		while playerLevel.CurrentEXP >=  playerLevel.RequiredEXP do

			if playerLevel.CurrentLevel >= maxLevel then
				playerLevel.CurrentLevel = maxLevel
				playerLevel.RequiredEXP = math.floor(100 * (maxLevel ^ 1.9))
				playerLevel.CurrentEXP = playerLevel.RequiredEXP
				return
			else
				playerLevel.CurrentLevel += 1
				playerLevel.CurrentEXP -= playerLevel.RequiredEXP

				playerLevel.RequiredEXP = math.floor(100 * (playerLevel.CurrentLevel ^ 1.9))
				playerLevel.StatPoints += 4
				NetworkingService:FireToClient(player, "PopUp", {
					["Level"] = playerLevel
				})
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
			task.wait(0.25)
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
	
	NetworkingService:FireToClient(player, "PopUp", {
		["EXP"] = EXP
	})
end

return LevelService
