local repstor = game:GetService("ReplicatedStorage")
local remotes = repstor.Remotes
local DataService = require(script.Parent.Parent.Services.DataService)


local LevelService = {}

function LevelService:SetupLevel(player)
	local LevelFolder = player:FindFirstChild("PlayerLevel")
	
	if not LevelFolder then
		LevelFolder = Instance.new("Folder")
		LevelFolder.Parent = player
		LevelFolder.Name = "PlayerLevel"

		local LevelValue = Instance.new("IntValue")
		LevelValue.Parent = LevelFolder
		LevelValue.Name = "CurrentLevel"

		local CurrentEXPValue = Instance.new("IntValue")
		CurrentEXPValue.Parent = LevelFolder
		CurrentEXPValue.Name = "CurrentEXP"

		local RequiredEXPValue = Instance.new("IntValue")
		RequiredEXPValue.Parent = LevelFolder
		RequiredEXPValue.Name = "RequiredEXP"

		local StatPointsValue = Instance.new("IntValue")
		StatPointsValue.Parent = LevelFolder
		StatPointsValue.Name = "StatPoints"
	end
	
end

function LevelService:IncreaseEXP(player , EXP)
	local playerLevel = DataService:GetTable(player , "Level")
	local levelFolder = player:WaitForChild("PlayerLevel")
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
				remotes.PopUp:FireClient(player, {
					["Level"] = playerLevel
				})
			end
			remotes.UpdateEXP:FireClient(player , playerLevel)
			levelFolder.CurrentLevel.Value = playerLevel.CurrentLevel
			levelFolder.CurrentEXP.Value = playerLevel.CurrentEXP
			levelFolder.RequiredEXP.Value = playerLevel.RequiredEXP
			levelFolder.StatPoints.Value = playerLevel.StatPoints
			wait(0.25)
		end
	end)
	levelFolder.CurrentLevel.Value = playerLevel.CurrentLevel
	levelFolder.CurrentEXP.Value = playerLevel.CurrentEXP
	levelFolder.RequiredEXP.Value = playerLevel.RequiredEXP
	levelFolder.StatPoints.Value = playerLevel.StatPoints
	
	remotes.UpdateEXP:FireClient(player , playerLevel)
	remotes.PopUp:FireClient(player, {
		["EXP"] = EXP
	})
end

return LevelService
