local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local EXPBar = require(ReplicatedStorage.Modules.Client.UI.Components.EXPBar)
local HealthBar = require(ReplicatedStorage.Modules.Client.UI.Components.HealthBar)
local ManaBar = require(ReplicatedStorage.Modules.Client.UI.Components.ManaBar)
local ReturnButton = require(ReplicatedStorage.Modules.Client.UI.Components.ReturnButton)
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local TitleData = require(ReplicatedStorage.Modules.Data.TitleData)
local FormulaApplier = require(ReplicatedStorage.Modules.Helpers.FormulaApplier)
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
	local activeTitle: StringValue = Player:WaitForChild("Titles"):FindFirstChild("ActiveTitle")
	local titleText = UIManager:GetUI("StatsMenu", "Overview"):FindFirstChild("Info"):FindFirstChild("Title")
	local function Title()
		local titleData = TitleData.Titles[activeTitle:GetAttribute("ID")]
		if not titleData then
			titleText.Text = "No Title"
			titleText:FindFirstChild("UIGradient").Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		else
			titleText.Text = titleData.Name
			if titleData.Color then
				titleText:FindFirstChild("UIGradient").Color = titleData.Color
			else
				titleText:FindFirstChild("UIGradient").Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			end
		end
	end
	Title()
	activeTitle.AttributeChanged:Connect(Title)

	--Level---
	local level: ImageButton = UIManager:GetUI("StatsMenu", "Level")
	local innerStroke = level:FindFirstChild("InnerStroke")
	UIHelper:RotateGradient(innerStroke:FindFirstChild("UIGradient"))

	local levelNumber = UIManager:GetUI("StatsMenu", "LevelNumber")
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
		local finalStat = Stat:GetAttribute("Final")
		local StatFrame = importantStatsFrame:FindFirstChild("Stats"):FindFirstChild(Stat.Name)
		if StatFrame then
			UIHelper:RotateGradient(StatFrame:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))
			local starsFrame = StatFrame:FindFirstChild("Stars")
			if starsFrame then
				for i, starMark in ipairs(starMarks) do
					if finalStat >= starMark then
						starsFrame["Star" .. i].Visible = true
					else
						starsFrame["Star" .. i].Visible = false
					end
				end
			else
				local statsNumber = StatFrame:FindFirstChild("StatNumber")
				if Stat.Name == "CriticalRate" or Stat.Name == "CriticalDamage" then
					local percentStat = Stat:GetAttribute("Percent")
					statsNumber.Text = (percentStat * 100) .. "%"
				else
					statsNumber.Text = finalStat
				end
			end
		end
	end
	for _, catagory in playerStats:GetChildren() do
		for _, Stat in catagory:GetChildren() do
			TotalStatsRefresh(Stat)
			Stat.AttributeChanged:Connect(function()
				TotalStatsRefresh(Stat)
			end)
		end
	end

	----Equipment----
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local Equipment = {}

	local folder = UIManager:GetUI("StatsMenu", "Equipment")
	for _, catagory in folder:GetChildren() do
		if catagory:IsA("Frame") then
			for _, type in catagory:GetChildren() do
				if type:IsA("Frame") then
					UIHelper:HoverEffects(type)
					UIHelper:RotateGradient(type:FindFirstChild("InnerStroke"):FindFirstChild("UIGradient"))
					UIHelper:RotateGradient(type:FindFirstChild("OuterStroke"):FindFirstChild("UIGradient"))
					Equipment[type.Name] = type
				end
			end
		end
	end

	local equipped = Player:WaitForChild("Equipped")
	local function UpdateEquipment()
		for type, frame in pairs(Equipment) do
			if frame:FindFirstChildWhichIsA("ImageButton") then
				frame:FindFirstChildWhichIsA("ImageButton"):Destroy()
			end
			if frame:FindFirstChild("EquippedItemPopup") then
				frame:FindFirstChild("EquippedItemPopup"):Destroy()
			end

			if equipped:FindFirstChild(type) and equipped:FindFirstChild(type):GetAttribute("Equipped") then
				local itemID = equipped:FindFirstChild(type):GetAttribute("Equipped")
				local itemData = ItemDataBase:GetItemData(itemID)
				if not itemData then
					continue
				end

				local icon = ReplicatedStorage.Assets.UI.Icons:FindFirstChild(itemData.Rarity .. "Item"):Clone()
				icon:FindFirstChild("OwnedAmount"):Destroy()
				icon:FindFirstChild("NameText"):Destroy()
				icon:FindFirstChild("Border"):Destroy()
				icon.Name = itemID
				icon.Icon.Image = itemData.Icon
				icon.Parent = frame

				icon.MouseButton1Click:Connect(function()
					local popup = frame:FindFirstChild("EquippedItemPopup")
					if popup then
						local tween = TweenService:Create(popup, info, { Size = UDim2.fromScale(0, 0.905) })
						tween:Play()
						tween.Completed:Connect(function()
							popup:Destroy()
						end)
						return
					end

					for _, otherInfoPopups in folder:GetDescendants() do
						if otherInfoPopups:IsA("Frame") then
							if otherInfoPopups.Name == "EquippedItemPopUp" then
								otherInfoPopups:Destroy()
							end
						end
					end

					popup = ReplicatedStorage.Assets.UI["EquippedItemPopup"]:Clone()
					popup.ItemName.Text = itemData.Name

					if itemData.Buffs then
						if itemData.Buffs.Health then
							if itemData.Buffs.Health.Percent then
								popup.FinalImportantStat.Text = "+" .. (itemData.Buffs.Health.Percent * 100) .. "%HP"
							else
								popup.FinalImportantStat.Text = "+" .. itemData.Buffs.Health.Flat .. " HP"
							end
						else
							if itemData.Buffs.Defense.Percent then
								popup.FinalImportantStat.Text = (itemData.Buffs.Defense.Percent * 100) .. "% DF"
							else
								popup.FinalImportantStat.Text = "+" .. itemData.Buffs.Defense.Flat .. " DF"
							end
						end
					else
						if itemData.Damage and playerStats.MainStats[type] then
							local M1Damage = FormulaApplier:M1Damage({
								PlayerDamageStat = playerStats.MainStats[type]:GetAttribute("Final"),
								FoundWeaponData = itemData,
								TargetDefenseStat = 0,
							})
							popup.FinalImportantStat.Text = M1Damage .. " ATK"
						elseif itemData.CriticalRate then
							popup.FinalImportantStat.Text = (
								itemData.CriticalRate
								* playerStats.SideStats.CriticalRate:GetAttrribute("Percent")
								* 100
							) .. " %CR"
						elseif itemData.CriticalDamage then
							popup.FinalImportantStat.Text = (
								itemData.CriticalDamage
								* playerStats.SideStats.CriticalDamage:GetAttribute("Percent")
								* 100
							) .. " %CR"
						end
					end

					if frame.Parent.Name == "Weapons" then
						popup.AnchorPoint = Vector2.new(0, 0.5)
						popup.Position = UDim2.fromScale(1.205, 0.835)
					elseif frame.Parent.Name == "Armors" then
						popup.AnchorPoint = Vector2.new(1, 0.5)
						popup.Position = UDim2.fromScale(-0.276, 0.835)
					end
					popup.Parent = frame
					TweenService:Create(popup, info, { Size = UDim2.fromScale(2.1, 0.905) }):Play()

					local unequipButton = popup:FindFirstChild("UnEquip")
					unequipButton.MouseEnter:Connect(function()
						TweenService:Create(unequipButton, info, { ImageColor3 = Color3.fromRGB(59, 59, 59) }):Play()
					end)

					unequipButton.MouseLeave:Connect(function()
						TweenService:Create(unequipButton, info, { ImageColor3 = Color3.fromRGB(39, 39, 39) }):Play()
					end)

					UIHelper:RotateGradient(popup:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))
					UIHelper:RotateGradient(unequipButton:FindFirstChild("RGBStroke"):FindFirstChild("UIGradient"))
					UIHelper:HoverEffects(unequipButton)
					UIHelper:ClickEffects(unequipButton)

					---unEquip Item---
					unequipButton.MouseButton1Click:Connect(function()
						local itemID = popup.Parent:FindFirstChildWhichIsA("ImageButton").Name
						NetworkingService:FireToServer("UnequipItem", itemID)
						popup:Destroy()
					end)
				end)
			end
		end
	end
	UpdateEquipment()
	equipped.ChildRemoved:Connect(UpdateEquipment)
	equipped.ChildAdded:Connect(UpdateEquipment)
end

function StatsMenuController:Stats() end

function StatsMenuController:Spells() end

function StatsMenuController:RiftBorn() end

function StatsMenuController:Armory() end

function StatsMenuController:Titles() end

return StatsMenuController
