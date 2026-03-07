local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
return function(statPointsFrame)
	local player = game:GetService("Players").LocalPlayer
	local repstore = game:GetService("ReplicatedStorage")
	local playerStats =  player:WaitForChild("PlayerStats")
	local tweenService = game:GetService("TweenService")
	local remotes = repstore.Remotes
	local statSections = statPointsFrame.StatSections

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	remotes.UpdateEXP.OnClientEvent:Connect(function(playerLevel)
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
				tweenService:Create(allocateButton["+"], info , {TextColor3 = Color3.fromRGB(255, 154, 213)}):Play()
				tweenService:Create(allocateButton.RGBStroke, info , {ImageColor3 = Color3.fromRGB(255, 154, 213)}):Play()
				tweenService:Create(allocateButton, info , {ImageColor3 = Color3.fromRGB(26, 21, 38)}):Play()
			end)

			allocateButton.MouseLeave:Connect(function()
				tweenService:Create(allocateButton["+"], info , {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
				tweenService:Create(allocateButton.RGBStroke, info , {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
				tweenService:Create(allocateButton, info , {ImageColor3 = Color3.fromRGB(30, 36, 66)}):Play()
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