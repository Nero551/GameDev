local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
return function(questMenu)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local TweenService = game:GetService("TweenService")
	local remotes = ReplicatedStorage.Remotes

	local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
	

	local questTemplate = ReplicatedStorage.Assets.GUI.Quest
	local questList = questMenu.QuestListFrame.QuestList.ScrollingFrame
	local questInfo = questMenu.QuestInfo


	local  info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function SizeIncrease(scale:UIScale)
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, {Scale = 1.025}):Play()
	end

	local function SizeDecrease(scale:UIScale)
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, {Scale = 1}):Play()
	end

	local function SizeClickDecrease(scale:UIScale)
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, {Scale = 0.975}):Play()
	end


	questInfo.Visible = false

	local questSelected = nil
	local prevQuestSelected = nil

	local trackedQuestFrame = questMenu.Parent.Parent:WaitForChild("OnScreenGUI").TrackedQuestFrame
	local trackedQuestName = trackedQuestFrame.TrackedQuestName


	local function UpdateQuestInfoFrame(questImgButton , quest) 

		for _, child in ipairs(questImgButton:GetChildren()) do
			print(child.Name, child.ClassName)
		end

		questInfo.Visible = true
		questInfo.QuestName.Text = questImgButton:WaitForChild("QuestName").Text
		questInfo.QuestDescription.Text = quest.QuestDescription
		questInfo.QuestType.Text = questImgButton:WaitForChild("QuestType").Text



		for objectiveNumber, objective in pairs(quest.Progress) do
			local objectiveFrame = questInfo.QuestProgress:FindFirstChild("Objective"..objectiveNumber)
			if not objectiveFrame then
				objectiveFrame = questImgButton.QuestProgress.ObjectiveTemplate:Clone()
				objectiveFrame.Name =  "Objective"..objectiveNumber
				objectiveFrame.Visible = true
				objectiveFrame.Parent = questInfo.QuestProgress
			end

			if objective.Item then
				objectiveFrame.ProgressText.Text = objective.ObjectiveType.." "..objective.Item.." "..objective.CurrentProgress.." / "..objective.Required

			elseif objective.Mob then
				objectiveFrame.ProgressText.Text = objective.ObjectiveType.." "..objective.Mob.." "..objective.CurrentProgress.." / "..objective.Required
			end
			TweenService:Create(objectiveFrame.ProgressBarBG.ProgressBar, info, {Size = UDim2.fromScale(math.min(objective.CurrentProgress/objective.Required) ,1)}):Play()
		end

		for reward,amount in pairs(quest.Rewards) do
			local rewardData = ItemDataBase:GetItemData(reward)
			if rewardData then
				local rewardFrame = ReplicatedStorage.Assets.GUI.Icons[rewardData.Rarity.."ItemFrame"]:Clone()
				rewardFrame.Parent = questInfo.QuestRewards
				rewardFrame.Name = reward
				rewardFrame:FindFirstChildWhichIsA("ImageButton").Name = reward
				local rewardIcon = rewardFrame[rewardFrame.Name]

				rewardIcon.Name = rewardFrame.Name
				rewardIcon.NameText.Text = ""
				rewardIcon.OwnedAmount.Text = amount
				rewardIcon.OwnedAmount.Size = UDim2.fromScale(1,0.204)
				rewardIcon.OwnedAmount.Position = UDim2.fromScale(0,0.8)
				rewardIcon.OwnedAmount.TextXAlignment = Enum.TextXAlignment.Center
				rewardIcon.Icon.Image = rewardData.Icon

			elseif reward == "ItemDrops" then
				for item,itemInfo in pairs(amount) do
					rewardData = ItemDataBase:GetItemData(item)
					if rewardData then
						local rewardFrame = ReplicatedStorage.Assets.GUI.Icons[rewardData.Rarity.."ItemFrame"]:Clone()
						rewardFrame.Parent = questInfo.QuestRewards
						rewardFrame.Name = item
						rewardFrame:FindFirstChildWhichIsA("ImageButton").Name = item
						local rewardIcon = rewardFrame[rewardFrame.Name]

						rewardIcon.Name = rewardFrame.Name
						rewardIcon.NameText.Text = ""
						rewardIcon.OwnedAmount.Text = itemInfo.Amount
						rewardIcon.OwnedAmount.Size = UDim2.fromScale(1,0.204)
						rewardIcon.OwnedAmount.Position = UDim2.fromScale(0,0.8)
						rewardIcon.OwnedAmount.TextXAlignment = Enum.TextXAlignment.Center
						rewardIcon.Icon.Image = rewardData.Icon
					end
				end		
			end	
		end
	end


	NetworkingService:OnClientEvent("UpdateQuests", function(playerQuests)

		---QuestFrame---
		for _,quest in questList:GetChildren() do

			if  quest:IsA("ImageButton") then
				if not playerQuests.ActiveQuests[quest.Name] then
					quest:Destroy()
					questInfo.Visible = false

				end
			end
		end

		for questID, quest in pairs(playerQuests.CompletedQuests) do
			local questImgButton:ImageButton? = questList:FindFirstChild(questID)
			if questImgButton then
				questImgButton:Destroy()
			end

			local completedQuestFrame = questList:FindFirstChild("Completed "..questID)
			if completedQuestFrame then
				completedQuestFrame:Destroy()
			end
		end

		for questID, quest in pairs(playerQuests.ActiveQuests) do

			local questImgButton = questList:FindFirstChild(questID)
			if not questImgButton then
				questImgButton = questTemplate:Clone()
				questImgButton.Name = questID
				questImgButton.QuestName.Text = quest.Name
				questImgButton.Parent = questList
				questImgButton.QuestType.Text = quest.QuestType
			end	


			if questImgButton then
				if playerQuests.TrackedQuest == questID then
					questImgButton.TrackQuestButton.Tracked.Enabled = true
					questImgButton.TrackQuestButton.Normal.Enabled = false
				else
					questImgButton.TrackQuestButton.Tracked.Enabled = false
					questImgButton.TrackQuestButton.Normal.Enabled = true
				end


				for objectiveNumber, objective in pairs(quest.Progress) do
					local objectiveFrame = questImgButton.QuestProgress:FindFirstChild("Objective"..objectiveNumber)
					if not objectiveFrame then
						objectiveFrame = questImgButton.QuestProgress.ObjectiveTemplate:Clone()
						objectiveFrame.Name =  "Objective"..objectiveNumber
						objectiveFrame.Visible = true
						objectiveFrame.Parent = questImgButton.QuestProgress
					end

					if objective.Item then
						objectiveFrame.ProgressText.Text = objective.ObjectiveType.." "..objective.Item.." "..objective.CurrentProgress.." / "..objective.Required

					elseif objective.Mob then
						objectiveFrame.ProgressText.Text = objective.ObjectiveType.." "..objective.Mob.." "..objective.CurrentProgress.." / "..objective.Required
					end
					TweenService:Create(objectiveFrame.ProgressBarBG.ProgressBar, info, {Size = UDim2.fromScale(math.min(objective.CurrentProgress/objective.Required) ,1)}):Play()
				end


				-----------------------------------------------------------------------------------------------------------------------------

				---LooksBS---
				local scale = questImgButton:FindFirstChild("UIScale")
				if not scale then
					scale = Instance.new("UIScale")
					scale.Parent = questImgButton
					scale.Name = "UIScale"
				end

				if not questImgButton:GetAttribute("Connected") then
					questImgButton:SetAttribute("Connected", true)
					questImgButton.MouseEnter:Connect(function()
						SizeIncrease(scale)
						if questSelected ~= questImgButton then
							TweenService:Create(questImgButton, info ,{ImageColor3 =  Color3.fromRGB(87, 107, 194)}):Play()

						end
					end)

					questImgButton.MouseLeave:Connect(function()
						SizeDecrease(scale)
						if questSelected ~= questImgButton then
							TweenService:Create(questImgButton, info ,{ImageColor3 =  Color3.fromRGB(255,255,255)}):Play()

						end
					end)

					questImgButton.MouseButton1Down:Connect(function()
						SizeClickDecrease(scale)
					end)

					questImgButton.MouseButton1Up:Connect(function()
						SizeIncrease(scale)
					end)



					---Quest Info---
					questImgButton.MouseButton1Click:Connect(function()
						for _,objective in questInfo.QuestProgress:GetChildren() do
							if objective:IsA("Frame") then
								objective:Destroy()
							end
						end

						for _, reward in questInfo.QuestRewards:GetChildren() do
							if reward:IsA("Frame") then
								reward:Destroy()
							end
						end
						UpdateQuestInfoFrame(questImgButton, quest)

						---Looks BS---
						prevQuestSelected = questSelected
						questSelected = questImgButton
						if  questSelected ~= nil then
							TweenService:Create(questSelected, info ,{ImageColor3 =  Color3.fromRGB(60, 49, 88)}):Play()
							TweenService:Create(questSelected.UIStroke, info, {Color = Color3.fromRGB(114, 142,255)}):Play()

							if prevQuestSelected ~= nil  then
								if prevQuestSelected ~= questSelected then
									TweenService:Create(prevQuestSelected, info ,{ImageColor3 =  Color3.fromRGB(255,255,255)}):Play()
									if prevQuestSelected:FindFirstChild("UIStroke") then
										TweenService:Create(prevQuestSelected.UIStroke, info, {Color = Color3.fromRGB(255,255,255)}):Play()
									end
								end
							end
						end
					end)
				end

			end	
		end

		-----------------------------------------------------------------------------------------------------------------------------

		---Tracked Quest Frame---
		local TquestID = playerQuests.TrackedQuest
		if TquestID  then
			local Tquest = playerQuests.ActiveQuests[TquestID]
			if Tquest then

				trackedQuestFrame.Visible = true
				trackedQuestName.Text = Tquest.Name

				local questFrame = questList:FindFirstChild(TquestID)
				if not questFrame then return end

				for _,objective in trackedQuestFrame.TrackedQuestProgress:GetChildren() do
					if objective:IsA("Frame") then
						objective:Destroy()
					end
				end

				for objectiveNumber, objective in pairs(Tquest.Progress) do
					local objectiveFrame = trackedQuestFrame.TrackedQuestProgress:FindFirstChild("Objective"..objectiveNumber)
					if not objectiveFrame then
						objectiveFrame = questFrame.QuestProgress.ObjectiveTemplate:Clone()
						objectiveFrame.Name =  "Objective"..objectiveNumber
						objectiveFrame.Visible = true
						objectiveFrame.Parent = trackedQuestFrame.TrackedQuestProgress
					end

					if objective.Item then
						objectiveFrame.ProgressText.Text = objective.ObjectiveType.." "..objective.Item.." "..objective.CurrentProgress.." / "..objective.Required

					elseif objective.Mob then
						objectiveFrame.ProgressText.Text = objective.ObjectiveType.." "..objective.Mob.." "..objective.CurrentProgress.." / "..objective.Required
					end
					TweenService:Create(objectiveFrame.ProgressBarBG.ProgressBar, info, {Size = UDim2.fromScale(math.min(objective.CurrentProgress/objective.Required) ,1)}):Play()
				end
			end

		else
			trackedQuestFrame.Visible = false
		end	
	end)

end
