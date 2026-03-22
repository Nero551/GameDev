local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local EXPBar = require(ReplicatedStorage.Modules.Client.UI.Components.EXPBar)
local HealthBar = require(ReplicatedStorage.Modules.Client.UI.Components.HealthBar)
local ManaBar = require(ReplicatedStorage.Modules.Client.UI.Components.ManaBar)
local ReturnButton = require(ReplicatedStorage.Modules.Client.UI.Components.ReturnButton)
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
local TitleData = require(ReplicatedStorage.Modules.Data.TitleData)
local StatsMenuController = {}

function StatsMenuController:TopBar()
	local topBar = UIManager:GetUI("StatsMenu", "TopBar")
	local menuName = topBar:FindFirstChild("MenuName")
	local StatsMenu = UIManager:GetUI("StatsMenu", "StatsMenu")
	local sectionButtons = UIManager:GetUI("StatsMenu", "SectionButtons")
	local isSliding = false
	UIHelper:RotateGradient(topBar:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))

	ReturnButton(UIManager:GetUI("StatsMenu", "StatsMenu"), UIManager:GetUI("StatsMenu", "ReturnButton"))

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, sectionButton in sectionButtons:GetChildren() do
		if sectionButton:IsA("ImageButton") then
			UIHelper:ClickEffects(sectionButton)
			UIHelper:HoverEffects(sectionButton)
			UIHelper:RotateGradient(sectionButton:FindFirstChild("UIGradient"))
			UIHelper:RotateGradient(sectionButton:FindFirstChild("RGBStroke"):FindFirstChild("UIGradient"))

			local sectionNames = sectionButton.Name
			local sectionMenus = StatsMenu:FindFirstChild(sectionNames)

			sectionButton.MouseButton1Click:Connect(function()
				local sectionName = sectionButton.Name
				local sectionMenu = StatsMenu:FindFirstChild(sectionName)
				if not sectionMenu then
					return
				end
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
				if sectionMenus.Position ~= UDim2.fromScale(-0.5, 0.558) then
					TweenService:Create(sectionButton.SectionName, info, { TextColor3 = Color3.fromRGB(255, 154, 213) })
						:Play()
					TweenService:Create(sectionButton.RGBStroke, info, { ImageColor3 = Color3.fromRGB(255, 154, 213) })
						:Play()
					TweenService:Create(sectionButton, info, { ImageColor3 = Color3.fromRGB(60, 49, 88) }):Play()
					TweenService:Create(sectionButton.SectionName, info, { TextStrokeTransparency = 0 }):Play()
				else
					TweenService:Create(sectionButton.SectionName, info, { TextColor3 = Color3.fromRGB(255, 255, 255) })
						:Play()
					TweenService:Create(sectionButton.RGBStroke, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
						:Play()
					TweenService:Create(sectionButton, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
					TweenService:Create(sectionButton.SectionName, info, { TextStrokeTransparency = 1 }):Play()
				end
			end
			SectionSelected()
			sectionMenus.Changed:Connect(function()
				SectionSelected()
			end)

			sectionButton.MouseEnter:Connect(function()
				if sectionMenus.Position == UDim2.fromScale(-0.5, 0.558) then
					TweenService:Create(sectionButton, info, { ImageColor3 = Color3.fromRGB(87, 107, 194) }):Play()
				end
			end)

			sectionButton.MouseLeave:Connect(function()
				if sectionMenus.Position == UDim2.fromScale(-0.5, 0.558) then
					TweenService:Create(sectionButton, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
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

function StatsMenuController:Overview()
	local Player = game:GetService("Players").LocalPlayer

	----Info----
	UIHelper:RotateGradient(
		UIManager:GetUI("StatsMenu", "Info"):FindFirstChild("UIStroke"):FindFirstChild("UIGradient")
	)

	---Health,Mana,EXP---
	HealthBar("StatsMenu")
	ManaBar("StatsMenu")
	EXPBar("StatsMenu")

	---Title---
	local title: StringValue = Player:WaitForChild("Titles"):FindFirstChild("ActiveTitle")
	local titleText = UIManager:GetUI("StatsMenu", "Overview"):FindFirstChild("Info"):FindFirstChild("Title")
	local function Title()
		local titleData = TitleData:GetTitleID(title.Value)
		if not titleData then
			titleText.Text = ""
		else
			titleText.Text = titleData.Name
			if titleData.Color then
				titleText:FindFirstChild("UIGradient").Color = titleData.Color
			end
		end
	end
	Title()
	title.Changed:Connect(function()
		Title()
	end)

	--Level---
	local level: ImageButton = UIManager:GetUI("StatsMenu", "Level")
	local innerStroke = level:FindFirstChild("InnerStroke")
	UIHelper:RotateGradient(innerStroke:FindFirstChild("UIGradient"))

	local levelNumber = UIManager:GetUI("HUD", "LevelNumber")
	local CurrentLevel: Instance = Player:WaitForChild("Level").CurrentLevel

	levelNumber.Text = CurrentLevel:GetAttribute("Amount")
	CurrentLevel:GetAttributeChangedSignal("Amount"):Connect(function()
		levelNumber.Text = CurrentLevel:GetAttribute("Amount")
	end)

	---Player Name---
	local PlayerNameText = UIManager:GetUI("StatsMenu", "PlayerName")
	UIHelper:RotateGradient(PlayerNameText.Parent:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))
	PlayerNameText.Text = Player.Name

	---Important Stats---
	local playerStats = Player:WaitForChild("Stats")
	local importantStatsFrame = UIManager:GetUI("StatsMenu", "ImportantStats")
	local maxStats = ReplicatedStorage.Values.MaxTotalStats.Value
	local starMarks = {
		maxStats * 0.05, --1st Star
		maxStats * 0.15, --2st Star
		maxStats * 0.35, --3st Star
		maxStats * 0.6, --4st Star
		maxStats * 1, --5st Star
	}

	local function TotalStatsRefresh(Stat)
		local finalStat = Stat:WaitForChild("Final")
		local StatFrame = importantStatsFrame:FindFirstChild("Stats"):FindFirstChild(Stat.Name)
		if StatFrame then
			UIHelper:RotateGradient(StatFrame:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))
			local starsFrame = StatFrame:FindFirstChild("Stars")
			if starsFrame then
				for i, starMark in pairs(starMarks) do
					if finalStat.Value >= starMark then
						starsFrame["Star" .. i].Visible = true
					else
						starsFrame["Star" .. i].Visible = false
					end
				end
			else
				local statsNumber = StatFrame:FindFirstChild("StatNumber")
				if Stat.Name == "CriticalRate" or Stat.Name == "CriticalDamage" then
					local percentStat = Stat.Percent
					statsNumber.Text = (percentStat.Value * 100) .. "%"
				else
					statsNumber.Text = finalStat.Value
				end
			end
		end
	end
	for _, catagory in playerStats:GetChildren() do
		for _, Stat in catagory:GetChildren() do
			TotalStatsRefresh(Stat)
			Stat.Final.Changed:Connect(function()
				TotalStatsRefresh(Stat)
			end)
			Stat.Percent.Changed:Connect(function()
				TotalStatsRefresh(Stat)
			end)
		end
	end

	----Equipment----
    
end

function StatsMenuController:Stats() end

function StatsMenuController:Spells() end

function StatsMenuController:RiftBorn() end

function StatsMenuController:Armory() end

function StatsMenuController:Titles() end

return StatsMenuController
