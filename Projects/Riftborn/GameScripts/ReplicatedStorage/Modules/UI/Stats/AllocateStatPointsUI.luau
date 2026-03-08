local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
return function(statPointsFrame)
	local Player = game:GetService("Players").LocalPlayer
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local playerStats =  Player:WaitForChild("PlayerStats")
	local TweenService = game:GetService("TweenService")
	local remotes = ReplicatedStorage.Remotes
	local statSections = statPointsFrame.StatSections

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	NetworkingService:OnClientEvent("UpdateEXP", function(playerLevel)
		statPointsFrame.AvailablePoints.Text = "Points: "..playerLevel.StatPoints
	end)


	for _,statFrame in statSections:GetChildren() do
		if statFrame:IsA("Frame") then
			local allocateButton:ImageButton = statFrame:FindFirstChild("AllocateButton(HoverClickSoundSizeChange)")
			allocateButton.MouseButton1Click:Connect(function()
				local amount = statPointsFrame.Amount.AmountText.Text
				if tonumber(amount) == nil then
					amount = 1
				end
				NetworkingService:FireToServer("AllocateStatPoint", statFrame.Name, tonumber(amount))
			end)
			allocateButton.MouseEnter:Connect(function()
				TweenService:Create(allocateButton["+"], info , {TextColor3 = Color3.fromRGB(255, 154, 213)}):Play()
				TweenService:Create(allocateButton.RGBStroke, info , {ImageColor3 = Color3.fromRGB(255, 154, 213)}):Play()
				TweenService:Create(allocateButton, info , {ImageColor3 = Color3.fromRGB(26, 21, 38)}):Play()
			end)

			allocateButton.MouseLeave:Connect(function()
				TweenService:Create(allocateButton["+"], info , {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
				TweenService:Create(allocateButton.RGBStroke, info , {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
				TweenService:Create(allocateButton, info , {ImageColor3 = Color3.fromRGB(30, 36, 66)}):Play()
			end)

		end
	end	

	for _,stat in playerStats:GetChildren() do
		local function StatPointsRefresh()
			local statPoints:NumberValue? = stat.FlatStatPoint
			for _,statFrame in statSections:GetChildren() do
				if statFrame:IsA("Frame") then
					if statFrame.Name == stat.Name then
						statFrame.StatNumber.Text = statPoints.Value
						if statPoints.Value == 3000 then
							statFrame.MaxedStatText.Visible = true
						else
							statFrame.MaxedStatText.Visible = false
						end
					end
				end
			end
		end
		StatPointsRefresh()

		stat.FlatStatPoint.Changed:Connect(function()
			StatPointsRefresh()
		end)
	end


end