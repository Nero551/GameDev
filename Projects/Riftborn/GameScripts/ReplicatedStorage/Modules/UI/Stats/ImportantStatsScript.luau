local repstor = game:GetService("ReplicatedStorage")
local maxStats = repstor.Values.MaxTotalStats.Value

local starMarks = {
	maxStats*0.05,  --1st Star
	maxStats*0.15, --2st Star
	maxStats*0.35, --3st Star
	maxStats*0.6,  --4st Star
	maxStats*1,    --5st Star
}


return function(importantStatsFrame)
	local player = game:GetService("Players").LocalPlayer
	local playerStats = player:WaitForChild("PlayerStats")

	for _,Stat  in playerStats:GetChildren() do
		local function TotalStatsRefresh()
			local  finalStat = Stat:WaitForChild("Final")
			local StatFrame = importantStatsFrame:FindFirstChild(Stat.Name)
			if StatFrame then
				local starsFrame = StatFrame:FindFirstChild("Stars")
				if starsFrame then
					for i,starMark in pairs(starMarks) do
						if  finalStat.Value >= starMark then
							starsFrame["Star"..i].Visible = true
						else
							starsFrame["Star"..i].Visible = false
						end
					end
				else
					local statsNumber = StatFrame:FindFirstChild("StatNumber")
					if Stat.Name == "CriticalRate" or Stat.Name == "CriticalDamage" then
						local percentStat = Stat.Percent
						statsNumber.Text = (percentStat.Value*100).."%"
					else
						statsNumber.Text = finalStat.Value
					end
				end

			end
		end
		TotalStatsRefresh()


		Stat.Final.Changed:Connect(function()
			TotalStatsRefresh()
		end)
		Stat.Percent.Changed:Connect(function()
			TotalStatsRefresh()
		end)
	end



end