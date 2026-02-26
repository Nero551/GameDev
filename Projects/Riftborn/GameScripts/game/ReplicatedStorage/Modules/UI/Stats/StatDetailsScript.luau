return function(statDetailsFrame)
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local playerStats = player:WaitForChild("PlayerStats")

	for _,stat in playerStats:GetChildren() do
		local function StatDetailsRefresh()
			local total = stat:WaitForChild("Final").Value
			local statPoints = stat.FlatStatPoint.Value
			local flatBonuses = stat.FlatBuff.Value
			local percentBonuses = (stat.Percent.Value * 100).."%"
			for _,statdetailFrame in  statDetailsFrame:GetDescendants() do
				if statdetailFrame:IsA("Frame") then
					if statdetailFrame.Name == stat.Name then
						local totalText:TextLabel = statdetailFrame.StatDetailNumbers.Total
						local statPointsText:TextLabel = statdetailFrame.StatDetailNumbers.StatPoint
						local flatBonusesText:TextLabel = statdetailFrame.StatDetailNumbers.FlatBonus
						local percentBonusesText:TextLabel = statdetailFrame.StatDetailNumbers.PercentBonus
						totalText.Text = total
						statPointsText.Text = statPoints
						flatBonusesText.Text = flatBonuses
						percentBonusesText.Text = percentBonuses
					end
				end
			end
		end
		StatDetailsRefresh()
		stat.Final.Changed:Connect(function()
			StatDetailsRefresh()
		end)
		stat.FlatStatPoint.Changed:Connect(function()
			StatDetailsRefresh()
		end)
		stat.FlatBuff.Changed:Connect(function()
			StatDetailsRefresh()
		end)
		stat.Percent.Changed:Connect(function()
			StatDetailsRefresh()
		end)
	end
end