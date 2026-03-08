local PlayerInfo = {}

function PlayerInfo:UpdateInfo(player, char)
	---Player Info GUI---
	local repstor = game:GetService("ReplicatedStorage")
	local tweenService = game:GetService("TweenService")
	local DataService = require(game.ServerScriptService.Services.DataService)
	local uiModules = repstor.Modules.UI

	if not player then return end

	local playerInfo = char.PlayerInfo
	local hpBG = playerInfo.PlayerHealth

	playerInfo.Adornee = char.Head
	playerInfo.PlayerToHideFrom = player


	---Health--
	local lastUpdate = tick()
	char:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(function()
		if tick() - lastUpdate > 0.1 then -- 20 FPS limit
			lastUpdate = tick()
			local hpChanger = require(uiModules.HPChangerUI)
			hpChanger(hpBG, char)
		end
	end)



	---Name---
	playerInfo.PlayerName.Text = char.Name

	---Level---
	local playerLevel = player:FindFirstChild("PlayerLevel")
	if not playerLevel then task.wait() end
	playerInfo.PlayerLevel.LevelText.Text = player:WaitForChild("PlayerLevel").CurrentLevel.Value
	player:WaitForChild("PlayerLevel").CurrentLevel.Changed:Connect(function()
		playerInfo.PlayerLevel.LevelText.Text = player:WaitForChild("PlayerLevel").CurrentLevel.Value
	end)


	---Title---
	local function TitleApplier()
		local playerTitles = DataService:GetTable(player, "Titles")
		if playerTitles.ActiveTitle then
			playerInfo.PlayerTitle.Visible = true
			playerInfo.PlayerTitle.Text = playerTitles.Titles[playerTitles.ActiveTitle].Name
			local colorTable = playerTitles.Titles[playerTitles.ActiveTitle].Color
			if colorTable then
				local keypoints = {}
				table.sort(colorTable, function(a,b) return a.Position < b.Position end)
				for _, color in ipairs(colorTable) do
					local r,g,b = color.Color:match("(%d+),%s*(%d+),%s*(%d+)")
					local c3 = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
					table.insert(keypoints, ColorSequenceKeypoint.new(color.Position, c3))
				end
				playerInfo.PlayerTitle.UIGradient.Color = ColorSequence.new(keypoints)

			else
				playerInfo.PlayerTitle.UIGradient.Color= ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),	
					ColorSequenceKeypoint.new(1, Color3.fromRGB(154, 154, 154))
				})
			end

			if playerInfo.PlayerTitle.UIGradient:FindFirstChild("RotationTween") then
				playerInfo.PlayerTitle.UIGradient.RotationTween:Destroy()
			end

			local tweenInfo = TweenInfo.new(16, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1 , true)
			if playerInfo.PlayerTitle.UIGradient:FindFirstChild("RotationTween") then
				playerInfo.PlayerTitle.UIGradient.RotationTween:Destroy()
			end
			local tween = tweenService:Create(playerInfo.PlayerTitle.UIGradient, tweenInfo, {Rotation = 360})
			tween.Name = "RotationTween"
			tween:Play()


		else
			playerInfo.PlayerTitle.Visible = false
		end

	end

	TitleApplier()

	player:WaitForChild("PlayerTitles").ActiveTitle.Changed:Connect(function()
		TitleApplier()
	end)
end

return PlayerInfo
