local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ConfirmPopup = require(ReplicatedStorage.Modules.Client.UI.Components.ConfirmPopup)
local ReturnButton = require(ReplicatedStorage.Modules.Client.UI.Components.ReturnButton)
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local QuestData = require(ReplicatedStorage.Modules.Data.QuestData)
local QuestMenuController = {}

function QuestMenuController:TopBar()
	local questList = UIManager:GetUI("QuestMenu", "QuestScrollingFrame")
	local Filters = UIManager:GetUI("QuestMenu", "QuestFilters")
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	ReturnButton("QuestMenu")

	local filterSelected = nil
	local prevFilterSelected = nil
	for _, filter in Filters:GetChildren() do
		if filter:IsA("TextButton") then
			UIHelper:ClickEffects(filter)
			UIHelper:HoverEffects(filter)

			filter.MouseButton1Click:Connect(function()
				prevFilterSelected = filterSelected
				filterSelected = filter

				if filterSelected ~= nil then
					TweenService
						:Create(filterSelected["TextLabel"], info, { TextColor3 = Color3.fromRGB(255, 154, 213) })
						:Play()
					TweenService:Create(filterSelected, info, { BackgroundColor3 = Color3.fromRGB(60, 49, 88) }):Play()
					if prevFilterSelected ~= nil then
						if prevFilterSelected ~= filterSelected then
							TweenService
								:Create(prevFilterSelected, info, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
								:Play()
							TweenService:Create(
								prevFilterSelected["TextLabel"],
								info,
								{ TextColor3 = Color3.fromRGB(255, 255, 255) }
							):Play()
						end
					end
				end

				---Filter---
				local filterType = filter.Name:split("Quests")[1] .. " Quest"
				for _, questSlot in questList:GetChildren() do
					if questSlot:IsA("ImageButton") then
						questSlot.Visible = true
						if filterType ~= "All Quest" then
							local questType = questSlot.QuestType.Text
							if questType ~= filterType then
								questSlot.Visible = false
							else
								questSlot.Visible = true
							end
						end
					end
				end
			end)

			filter.MouseEnter:Connect(function()
				if filterSelected ~= filter then
					TweenService:Create(filter, info, { BackgroundColor3 = Color3.fromRGB(87, 107, 194) }):Play()
				end
			end)

			filter.MouseLeave:Connect(function()
				if filterSelected ~= filter then
					TweenService:Create(filter, info, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				end
			end)
		end
	end
end

function QuestMenuController:Quests()
	local player = Players.LocalPlayer
	local Quests = player:WaitForChild("Quests")
	local questList = UIManager:GetUI("QuestMenu", "QuestScrollingFrame")
	local questInfo = UIManager:GetUI("QuestMenu", "QuestInfo")

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local questSelected = nil
	local prevQuestSelected = nil

	for _, questSlot in questList:GetChildren() do
		if questSlot:IsA("ImageButton") then
			questSlot:Destroy()
		end
	end

	local function UpdateUI(child, remove)
		local questID = child.Name
		local questData = QuestData.Quests[questID]

		questInfo.Visible = false

		if QuestData then
			local questSlot = questList:FindFirstChild(questID)
			if questSlot and remove then
				questSlot:Destroy()
				return
			end
			if not questSlot then
				questSlot =
					UIManager:CloneUI("QuestMenu", questID, ReplicatedStorage.Assets.UI.Quest, "QuestScrollingFrame")
				questSlot.QuestName.TextLabel.Text = questData.Name
				questSlot.QuestType.TextLabel.Text = questData.QuestType
				UIHelper:RotateGradient(questSlot:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))
				UIHelper:ClickEffects(questSlot, 1.025, 0.975)
				UIHelper:HoverEffects(questSlot, 1.025, 1)

				UIHelper:ClickEffects(questSlot.TrackQuestButton)
				UIHelper:HoverEffects(questSlot.TrackQuestButton)
				questSlot.TrackQuestButton.MouseButton1Click:Connect(function()
					NetworkingService:FireToServer("TrackQuest", questID)
				end)

				for _, objective in child:GetChildren() do
					local objectiveNumber = objective.Name
					local objectiveFrame = questSlot.QuestProgress:FindFirstChild(objectiveNumber)
					if not objectiveFrame then
						objectiveFrame = UIManager:CloneUI(
							"QuestMenu",
							objectiveNumber,
							questSlot.QuestProgress.ObjectiveTemplate,
							questSlot.Name
						)
						objectiveFrame.Visible = true
						UIHelper:RotateGradient(
							objectiveFrame
								:FindFirstChild("ProgressBarBG")
								:FindFirstChild("UIStroke")
								:FindFirstChild("UIGradient")
						)
					end

					if objective:GetAttribute("Item") then
						objectiveFrame.ProgressText.Text = objective:GetAttribute("ObjectiveType")
							.. " "
							.. objective:GetAttribute("Item")
							.. " "
							.. tostring(objective:GetAttribute("Current"))
							.. " / "
							.. tostring(objective:GetAttribute("Required"))
					elseif objective:GetAttribute("Mob") then
						objectiveFrame.ProgressText.Text = objective:GetAttribute("ObjectiveType")
							.. " "
							.. objective:GetAttribute("Mob")
							.. " "
							.. tostring(objective:GetAttribute("Current"))
							.. " / "
							.. tostring(objective:GetAttribute("Required"))
					end
					TweenService:Create(objectiveFrame.ProgressBarBG.ProgressBar, info, {
						Size = UDim2.fromScale(
							math.min(objective:GetAttribute("Current") / objective:GetAttribute("Required")),
							1
						),
					}):Play()
				end

				questSlot.MouseEnter:Connect(function()
					if questSelected ~= questSlot then
					end
				end)

				questSlot.MouseLeave:Connect(function()
					if questSelected ~= questSlot then
					end
				end)

				---Quest Info---
				questSlot.MouseButton1Click:Connect(function()
					for _, objective in questInfo.QuestInfoProgress:GetChildren() do
						if objective:IsA("Frame") then
							objective:Destroy()
						end
					end

					for _, reward in questInfo.QuestInfoRewards:GetChildren() do
						if reward:IsA("ImageButton") then
							reward:Destroy()
						end
					end

					questInfo.Visible = true
					questInfo.QuestName.TextLabel.Text = questSlot.QuestName.TextLabel.Text
					questInfo.QuestDescription.Text = questData.Description
					questInfo.QuestType.Text = questSlot.QuestType.TextLabel.Text

					for _, objective in child:GetChildren() do
						local objectiveNumber = objective.name
						local objectiveFrame = questInfo.QuestInfoProgress:FindFirstChild(objectiveNumber)
						if not objectiveFrame then
							objectiveFrame = UIManager:CloneUI(
								"QuestMenu",
								objectiveNumber,
								ReplicatedStorage.Assets.UI.Quest.QuestProgress.ObjectiveTemplate,
								"QuestInfoProgress"
							)
							objectiveFrame.Visible = true
						end

						if objective:GetAttribute("Item") then
							objectiveFrame.ProgressText.Text = objective:GetAttribute("ObjectiveType")
								.. " "
								.. objective:GetAttribute("Item")
								.. " "
								.. tostring(objective:GetAttribute("Current"))
								.. " / "
								.. tostring(objective:GetAttribute("Required"))
						elseif objective:GetAttribute("Mob") then
							objectiveFrame.ProgressText.Text = objective:GetAttribute("ObjectiveType")
								.. " "
								.. objective:GetAttribute("Mob")
								.. " "
								.. tostring(objective:GetAttribute("Current"))
								.. " / "
								.. tostring(objective:GetAttribute("Required"))
						end
						TweenService
							:Create(objectiveFrame.ProgressBarBG.ProgressBar, info, {
								Size = UDim2.fromScale(
									math.min(objective:GetAttribute("Current") / objective:GetAttribute("Required")),
									1
								),
							})
							:Play()
					end

					for reward, amount in pairs(questData.Rewards) do
						local rewardData = ItemDataBase:GetItemData(reward)
						if rewardData then
							local rewardSlot = UIManager:CloneUI(
								"QuestMenu",
								reward,
								ReplicatedStorage.Assets.UI.Icons[rewardData.Rarity .. "Item"],
								"QuestInfoRewards"
							)
							rewardSlot.NameText.Text = ""
							rewardSlot.OwnedAmount.Text = amount
							rewardSlot.OwnedAmount.Size = UDim2.fromScale(1, 0.204)
							rewardSlot.OwnedAmount.Position = UDim2.fromScale(0, 0.8)
							rewardSlot.OwnedAmount.TextXAlignment = Enum.TextXAlignment.Center
							rewardSlot.Icon.Image = rewardData.Icon
						elseif reward == "ItemDrops" then
							for item, itemInfo in pairs(amount) do
								rewardData = ItemDataBase:GetItemData(item)
								if rewardData then
									local rewardSlot = UIManager:CloneUI(
										"QuestMenu",
										item,
										ReplicatedStorage.Assets.UI.Icons[rewardData.Rarity .. "Item"],
										"QuestInfoRewards"
									)

									rewardSlot.NameText.Text = ""
									rewardSlot.OwnedAmount.Text = itemInfo.Amount
									rewardSlot.OwnedAmount.Size = UDim2.fromScale(1, 0.204)
									rewardSlot.OwnedAmount.Position = UDim2.fromScale(0, 0.8)
									rewardSlot.OwnedAmount.TextXAlignment = Enum.TextXAlignment.Center
									rewardSlot.Icon.Image = rewardData.Icon
								end
							end
						end
					end

					prevQuestSelected = questSelected
					questSelected = questSlot
					if questSelected ~= nil then
						if prevQuestSelected ~= nil then
							if prevQuestSelected ~= questSelected then
								if prevQuestSelected:FindFirstChild("UIStroke") then
								end
							end
						end
					end
				end)
			end
		end
	end

	for _, folder in Quests:GetChildren() do
		if folder:IsA("Folder") then
			for _, child in folder:GetChildren() do
				UpdateUI(child)
				for _, objective in child:GetChildren() do
					objective.AttributeChanged:Connect(function()
						UpdateUI(child)
					end)
				end
			end
			folder.ChildAdded:Connect(function(child)
				for _, objective in child:GetChildren() do
					objective.AttributeChanged:Connect(function()
						UpdateUI(child)
					end)
				end
				UpdateUI(child)
			end)
			folder.ChildRemoved:Connect(function(child)
				UpdateUI(child, true)
			end)
		end
	end

	local function UpdateTracked()
		for _, questSlot in questList:GetChildren() do
			if questSlot:IsA("ImageButton") then
				if Quests:FindFirstChild("TrackedQuest"):GetAttribute("ID") == questSlot.Name then
					questSlot.TrackQuestButton.Tracked.Enabled = true
					questSlot.TrackQuestButton.Normal.Enabled = false
				else
					questSlot.TrackQuestButton.Tracked.Enabled = false
					questSlot.TrackQuestButton.Normal.Enabled = true
				end
			end
		end
	end
	UpdateTracked()
	Quests:FindFirstChild("TrackedQuest"):GetAttributeChangedSignal("ID"):Connect(UpdateTracked)
end

function QuestMenuController:AbandonQuest()
	local questInfo = UIManager:GetUI("QuestMenu", "QuestInfo")
	local abandonQuestButton = questInfo:FindFirstChild("AbandonQuest")
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	UIHelper:HoverEffects(abandonQuestButton)
	UIHelper:ClickEffects(abandonQuestButton)

	local confirmPopup
	local confirmConnection

	local function GetConfirmPopup()
		if confirmPopup and confirmPopup.Parent then
			return confirmPopup
		end

		confirmPopup = ConfirmPopup()

		confirmPopup:GetPropertyChangedSignal("Visible"):Connect(function()
			if confirmPopup.Visible then
				TweenService
					:Create(abandonQuestButton.AbandonQuestText, info, { TextColor3 = Color3.fromRGB(255, 154, 213) })
					:Play()
				TweenService:Create(abandonQuestButton.RGBStroke, info, { ImageColor3 = Color3.fromRGB(255, 154, 213) })
					:Play()
				TweenService:Create(abandonQuestButton, info, { ImageColor3 = Color3.fromRGB(60, 49, 88) }):Play()
			else
				TweenService:Create(abandonQuestButton, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				TweenService:Create(abandonQuestButton.RGBStroke, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
					:Play()
				TweenService
					:Create(abandonQuestButton.AbandonQuestText, info, { TextColor3 = Color3.fromRGB(255, 255, 255) })
					:Play()
			end
		end)

		return confirmPopup
	end

	-----------------------------------------------------------------------------------------------------------------------------
	abandonQuestButton.MouseButton1Click:Connect(function()
		local popup = GetConfirmPopup()
		local confirmButton = popup:FindFirstChild("ConfirmButton")

		popup.TextLabel.Text = "Abandon Quest?"
		popup.Visible = true
		TweenService:Create(popup, info, {
			Size = UDim2.fromScale(0.262, 0.49),
		}):Play()

		if confirmConnection then
			confirmConnection:Disconnect()
		end

		confirmConnection = confirmButton.MouseButton1Click:Connect(function()
			local questName = abandonQuestButton.Parent.QuestName.Text
			NetworkingService:FireToServer("AbandonQuest", questName)
			questInfo.Visible = false
			popup.Visible = false
		end)
	end)

	-----------------------------------------------------------------------------------------------------------------------------
	abandonQuestButton.MouseEnter:Connect(function()
		if confirmPopup and not confirmPopup.Visible then
			TweenService:Create(abandonQuestButton, info, { ImageColor3 = Color3.fromRGB(87, 107, 194) }):Play()
		end
	end)

	-----------------------------------------------------------------------------------------------------------------------------
	abandonQuestButton.MouseLeave:Connect(function()
		if confirmPopup and not confirmPopup.Visible then
			TweenService:Create(abandonQuestButton, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		end
	end)
end

return QuestMenuController
