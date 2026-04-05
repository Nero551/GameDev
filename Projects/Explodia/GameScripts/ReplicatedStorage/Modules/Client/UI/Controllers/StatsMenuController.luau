local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ConfirmPopup = require(ReplicatedStorage.Modules.Client.UI.Components.ConfirmPopup)
local ReturnButton = require(ReplicatedStorage.Modules.Client.UI.Components.ReturnButton)
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local StatsMenuController = {}

function StatsMenuController:TopBar()
	local topBar = UIManager:GetUI("StatsMenu", "TopBar")
	local menuName = topBar:FindFirstChild("MenuName")
	local StatsMenu = UIManager:GetUI("StatsMenu", "StatsMenu")
	local sectionButtons = UIManager:GetUI("StatsMenu", "SectionButtons")
	local isSliding = false

	ReturnButton("StatsMenu")

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, sectionButton in sectionButtons:GetChildren() do
		if sectionButton:IsA("TextButton") then
			UIHelper:ClickEffects(sectionButton)
			UIHelper:HoverEffects(sectionButton)

			local sectionName = sectionButton.Name:split("Button")[1]
			local sectionMenu = StatsMenu:FindFirstChild(sectionName)

			sectionButton.MouseButton1Click:Connect(function()
				for _, frame in StatsMenu:GetChildren() do
					if frame:IsA("Frame") then
						if frame.Name ~= "TopBar" then
							if frame.Name ~= sectionName then
								frame.Visible = false
								frame.Position = UDim2.fromScale(-0.5, 0.558)
							end
						end
					end
				end
				sectionMenu.Visible = true
				if isSliding then
					return
				end
				isSliding = true
				local info = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
				local tween = TweenService:Create(sectionMenu, info, { Position = UDim2.fromScale(0.5, 0.558) })
				tween:Play()
				tween.Completed:Connect(function()
					isSliding = false
				end)
			end)

			---Looks BS---
			local function SectionSelected()
				if sectionMenu.Position ~= UDim2.fromScale(-0.5, 0.558) then
					TweenService:Create(sectionButton.TextLabel, info, { TextColor3 = Color3.fromRGB(221, 211, 22) })
						:Play()
					TweenService:Create(sectionButton, info, { BackgroundColor3 = Color3.fromRGB(60, 49, 88) }):Play()
					TweenService:Create(sectionButton.TextLabel, info, { TextStrokeTransparency = 0 }):Play()
				else
					TweenService:Create(sectionButton.TextLabel, info, { TextColor3 = Color3.fromRGB(255, 255, 255) })
						:Play()
					TweenService:Create(sectionButton, info, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
						:Play()
					TweenService:Create(sectionButton.TextLabel, info, { TextStrokeTransparency = 1 }):Play()
				end
			end
			SectionSelected()
			sectionMenu.Changed:Connect(function()
				SectionSelected()
			end)

			sectionButton.MouseEnter:Connect(function()
				if sectionMenu.Position == UDim2.fromScale(-0.5, 0.558) then
					TweenService:Create(sectionButton, info, { BackgroundColor3 = Color3.fromRGB(87, 107, 194) }):Play()
				end
			end)

			sectionButton.MouseLeave:Connect(function()
				if sectionMenu.Position == UDim2.fromScale(-0.5, 0.558) then
					TweenService:Create(sectionButton, info, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
						:Play()
				end
			end)
		end
	end

	for _, sectionMenu in StatsMenu:GetChildren() do
		if sectionMenu:IsA("Frame") then
			if sectionMenu.Name ~= "TopBar" then
				sectionMenu.Changed:Connect(function()
					if sectionMenu.Visible == true then
						menuName.Text = sectionMenu.Name
					end
				end)
			end
		end
	end
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

	UIHelper:ClickEffects(resetButton)
	UIHelper:HoverEffects(resetButton)

	statPointsFrame:FindFirstChild("AvailablePoints").Text = "Points: "
		.. playerLevel:FindFirstChild("StatPoints"):GetAttribute("Amount")
	playerLevel:FindFirstChild("StatPoints"):GetAttributeChangedSignal("Amount"):Connect(function()
		statPointsFrame:FindFirstChild("AvailablePoints").Text = "Points: "
			.. playerLevel:FindFirstChild("StatPoints"):GetAttribute("Amount")
	end)

	for _, statFrame in statSections:GetChildren() do
		if statFrame:IsA("Frame") then
			local allocateButton = statFrame:FindFirstChild("AllocateButton")
			UIHelper:ClickEffects(allocateButton)
			UIHelper:HoverEffects(allocateButton)
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
						ReplicatedStorage.Assets.UI.StatDetailTemplate,
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
					textLabel.Text = boost..":  "..val
				end
			end
			local function StatPointsRefresh()
				if stat.Parent.Name ~= "MainStats" then
					return
				end

				local statPoints = stat:GetAttribute("FlatStatPoint")
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

function StatsMenuController:RandomGradients()
	local texture = UIManager:GetUI("StatsMenu", "Texture")
	UIHelper:RotateGradient(texture:FindFirstChild("UIGradient"))
end

return StatsMenuController
