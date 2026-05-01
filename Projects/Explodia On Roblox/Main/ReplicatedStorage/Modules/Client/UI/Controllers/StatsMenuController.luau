local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ConfirmPopup = require(ReplicatedStorage.Modules.Client.UI.Components.ConfirmPopup)
local ReturnButton = require(ReplicatedStorage.Modules.Client.UI.Components.ReturnButton)
local ClickHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.ClickHelper)
local HoverHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.HoverHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local StatsMenuController = {}

function StatsMenuController:TopBar()
	ReturnButton("StatsMenu")
end

function StatsMenuController:Stats()
	local player = game:GetService("Players").LocalPlayer
	local playerStats = player:WaitForChild("Stats")
	local playerLevel = player:WaitForChild("Level")
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local resetButton = UIManager:GetUI("StatsMenu", "ResetButton")
	local statDetailsFrame = UIManager:GetUI("StatsMenu", "StatDetailsFrame")
	local statPointsFrame = UIManager:GetUI("StatsMenu", "StatPointsFrame")
	local statSections = statPointsFrame:FindFirstChild("StatSections")

	HoverHelper:HoverEffects(resetButton)
	ClickHelper:ClickEffects(resetButton)

	statPointsFrame:FindFirstChild("AvailablePoints").Text = "Points: "
		.. playerLevel:FindFirstChild("StatPoints"):GetAttribute("Amount")
	playerLevel:FindFirstChild("StatPoints"):GetAttributeChangedSignal("Amount"):Connect(function()
		statPointsFrame:FindFirstChild("AvailablePoints").Text = "Points: "
			.. playerLevel:FindFirstChild("StatPoints"):GetAttribute("Amount")
	end)

	for _, statFrame in statSections:GetChildren() do
		if statFrame:IsA("Frame") then
			local allocateButton = statFrame:FindFirstChild("AllocateButton")

			HoverHelper:HoverEffects(allocateButton)
			ClickHelper:ClickEffects(allocateButton)
			
			allocateButton.MouseButton1Click:Connect(function()
				local amount = statPointsFrame.Amount.AmountBox.Text
				if tonumber(amount) == nil then
					amount = 1
				end
				NetworkingService:FireToServer("AllocateStatPoint", statFrame.Name, tonumber(amount))
			end)
			allocateButton.MouseEnter:Connect(function() end)

			allocateButton.MouseLeave:Connect(function() end)
		end
	end

	for _, catagory in playerStats:GetChildren() do
		for _, stat in catagory:GetChildren() do
			local function StatDetailsRefresh()
				local detailFrame = statDetailsFrame:FindFirstChild(stat.Name)
				if not detailFrame then
					detailFrame = UIManager:CloneUI(
						"StatsMenu",
						stat.Name,
						player.PlayerGui.UITemplates.StatDetailTemplate,
						"StatDetailsFrame"
					)
					detailFrame.StatCatagory.Text = stat.Name
				end
				for boost, val in stat:GetAttributes() do
					local textLabel = detailFrame:FindFirstChild("Details"):FindFirstChild(boost)
					if not textLabel then
						textLabel = detailFrame:FindFirstChild("Details"):FindFirstChild("Final"):Clone()
						textLabel.Name = boost
						textLabel.Parent = detailFrame:FindFirstChild("Details")
					end
					textLabel.Visible = true
					textLabel.Text = boost .. ":  " .. val
				end
			end
			local function StatPointsRefresh()
				if stat.Parent.Name ~= "MainStats" then
					return
				end

				local statPoints = stat:GetAttribute("StatPoint")
				for _, statFrame in statSections:GetChildren() do
					if not statFrame:IsA("Frame") then
						continue
					end
					if statFrame.Name ~= stat.Name then
						continue
					end
					statFrame.StatNumber.Text = statPoints
				end
			end

			StatDetailsRefresh()
			StatPointsRefresh()
			stat.AttributeChanged:Connect(function()
				StatDetailsRefresh()
				StatPointsRefresh()
			end)
		end
	end

	local confirmPopUp = nil
	local confirmConnection = nil

	local function GetConfirmPopup()
		if confirmPopUp and confirmPopUp.Parent then
			return confirmPopUp
		end

		confirmPopUp = ConfirmPopup()

		confirmPopUp:GetPropertyChangedSignal("Visible"):Connect(function()
			if confirmPopUp.Visible then
			else
			end
		end)

		return confirmPopUp
	end

	resetButton.MouseButton1Click:Connect(function()
		local popup = GetConfirmPopup()
		local confirmButton = popup:FindFirstChild("ConfirmButton")

		popup.TextLabel.Text = "Reset Stats?"
		popup.Visible = true
		TweenService:Create(popup, info, { Size = UDim2.fromScale(0.262, 0.49) }):Play()

		if confirmConnection then
			confirmConnection:Disconnect()
		end

		confirmConnection = confirmButton.MouseButton1Click:Connect(function()
			NetworkingService:FireToServer("ResetStatPoints")
			popup:Destroy()
		end)
	end)
end

return StatsMenuController
