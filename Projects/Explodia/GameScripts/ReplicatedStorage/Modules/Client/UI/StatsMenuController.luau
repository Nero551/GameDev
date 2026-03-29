local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ConfirmPopup = require(ReplicatedStorage.Modules.Client.UI.Components.ConfirmPopup)
local EXPBar = require(ReplicatedStorage.Modules.Client.UI.Components.EXPBar)
local HealthBar = require(ReplicatedStorage.Modules.Client.UI.Components.HealthBar)
local ManaBar = require(ReplicatedStorage.Modules.Client.UI.Components.ManaBar)
local ReturnButton = require(ReplicatedStorage.Modules.Client.UI.Components.ReturnButton)
local StaminaBar = require(ReplicatedStorage.Modules.Client.UI.Components.StaminaBar)
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local AbilityData = require(ReplicatedStorage.Modules.Data.AbilityData)
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local RarityData = require(ReplicatedStorage.Modules.Data.RarityData)
local TitleData = require(ReplicatedStorage.Modules.Data.TitleData)
local FormulaApplier = require(ReplicatedStorage.Modules.Helpers.FormulaApplier)
local StatsMenuController = {}

function StatsMenuController:TopBar()
	local topBar = UIManager:GetUI("StatsMenu", "TopBar")
	local menuName = topBar:FindFirstChild("MenuName")
	local StatsMenu = UIManager:GetUI("StatsMenu", "StatsMenu")
	local sectionButtons = UIManager:GetUI("StatsMenu", "SectionButtons")
	local isSliding = false

	--ReturnButton(UIManager:GetUI("StatsMenu", "StatsMenu"), UIManager:GetUI("StatsMenu", "ReturnButton"))

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for _, sectionButton in sectionButtons:GetChildren() do
		if sectionButton:IsA("TextButton") then
			UIHelper:ClickEffects(sectionButton)
			UIHelper:HoverEffects(sectionButton)

			local sectionName = sectionButton.Name
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
					TweenService:Create(sectionButton, info, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
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
					TweenService:Create(sectionButton, info, { BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
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
	---Health,Mana,EXP---
	HealthBar("StatsMenu")
	ManaBar("StatsMenu")
	EXPBar("StatsMenu")
	StaminaBar("StatsMenu")

	---Title---
	local activeTitle: StringValue = Player:WaitForChild("Titles"):FindFirstChild("ActiveTitle")
	local titleText = UIManager:GetUI("StatsMenu", "Overview"):FindFirstChild("Info"):FindFirstChild("Title")
	UIHelper:RotateGradient(titleText:FindFirstChild("UIGradient", 16))
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
	local levelNumber = UIManager:GetUI("StatsMenu", "LevelNumber")
	local CurrentLevel: Instance = Player:WaitForChild("Level").CurrentLevel

	levelNumber.Text = CurrentLevel:GetAttribute("Amount")
	CurrentLevel:GetAttributeChangedSignal("Amount"):Connect(function()
		levelNumber.Text = CurrentLevel:GetAttribute("Amount")
	end)

	---Player Name---
	local PlayerNameText = UIManager:GetUI("StatsMenu", "PlayerName")
	PlayerNameText.Text = Player.Name

	---Important Stats---
	local playerStats = Player:WaitForChild("Stats")
	local importantStatsFrame = UIManager:GetUI("StatsMenu", "ImportantStats")

	local function TotalStatsRefresh(Stat)
		local finalStat = Stat:GetAttribute("Final")
		local StatFrame = importantStatsFrame:FindFirstChild("Stats"):FindFirstChild(Stat.Name)
		if StatFrame then
			local statsNumber = StatFrame:FindFirstChild("StatNumber")
			statsNumber.Text = finalStat
		end
	end
	for _, Stat in playerStats.MainStats:GetChildren() do
		TotalStatsRefresh(Stat)
		Stat.AttributeChanged:Connect(function()
			TotalStatsRefresh(Stat)
		end)
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

				local icon = UIManager:CloneUI(
					"StatsMenu",
					itemID,
					ReplicatedStorage.Assets.UI.Icons:FindFirstChild(itemData.Rarity .. "Item"),
					frame.Name
				)
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
						if itemData.Damage and playerStats.MainStats.Strength then
							local M1Damage = FormulaApplier:DefaultDamage(
								itemData.Damage,
								playerStats.MainStats.Strength:GetAttribute("Final"),
								0
							)
							popup.FinalImportantStat.Text = M1Damage .. " ATK"
						elseif itemData.CriticalRate then
							popup.FinalImportantStat.Text = (
								itemData.CriticalRate
								* playerStats.SideStats.CriticalRate:GetAttribute("Percent")
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

function StatsMenuController:Stats()
	local player = game:GetService("Players").LocalPlayer
	local playerStats = player:WaitForChild("Stats")
	local playerLevel = player:WaitForChild("Level")
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local resetButton = UIManager:GetUI("StatsMenu", "ResetButton")
	local statDetailsFrame = UIManager:GetUI("StatsMenu", "StatDetailsFrame"):FindFirstChild("Stats")
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
				local amount = statPointsFrame.AmountBox.Amount.Text
				if tonumber(amount) == nil then
					amount = 1
				end
				NetworkingService:FireToServer("AllocateStatPoint", statFrame.Name, tonumber(amount))
			end)
			allocateButton.MouseEnter:Connect(function()
				UIHelper:SwitchColors(allocateButton, allocateButton.TextLabel)
			end)

			allocateButton.MouseLeave:Connect(function()
				UIHelper:SwitchColors(allocateButton, allocateButton.TextLabel)
			end)
		end
	end

	for _, detailFrame in statDetailsFrame:GetDescendants() do
		if detailFrame:IsA("Frame") then
			if detailFrame:FindFirstChild("StatCatagory") then
			end
		end
	end
	for _, catagory in playerStats:GetChildren() do
		for _, stat in catagory:GetChildren() do
			local function StatDetailsRefresh()
				local total = stat:GetAttribute("Final")
				local statPoints = stat:GetAttribute("FlatStatPoint")
				local flatBonuses = stat:GetAttribute("FlatBuff")
				local percentBonuses = (stat:GetAttribute("Percent") * 100) .. "%"
				for _, detailFrame in statDetailsFrame:GetDescendants() do
					if not detailFrame:IsA("Frame") then
						continue
					end
					if detailFrame.Name ~= stat.Name then
						continue
					end
					local totalText: TextLabel = detailFrame.StatDetailNumbers.Total
					local statPointsText: TextLabel = detailFrame.StatDetailNumbers.StatPoint
					local flatBonusesText: TextLabel = detailFrame.StatDetailNumbers.FlatBonus
					local percentBonusesText: TextLabel = detailFrame.StatDetailNumbers.PercentBonus
					totalText.Text = total
					statPointsText.Text = statPoints
					flatBonusesText.Text = flatBonuses
					percentBonusesText.Text = percentBonuses
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
				UIHelper:SwitchColors(resetButton, resetButton.ResetText)
			else
				UIHelper:SwitchColors(resetButton, resetButton.ResetText)
			end
		end)

		return confirmPopUp
	end

	resetButton.MouseButton1Click:Connect(function()
		local popup = GetConfirmPopup()
		local confirmButton = popup:FindFirstChild("ConfirmButton")

		popup.TextLabel.Text = "Reset Stats?"
		popup.Visible = true
		TweenService:Create(popup, info, { Size = UDim2.fromScale(0.262, 0.49)}):Play()

		if confirmConnection then
			confirmConnection:Disconnect()
		end

		confirmConnection = confirmButton.MouseButton1Click:Connect(function()
			NetworkingService:FireToServer("ResetStatPoints")
			popup:Destroy()
		end)
	end)
end

function StatsMenuController:Spells() end

function StatsMenuController:RiftBorn() end

function StatsMenuController:Titles()
	local player = Players.LocalPlayer
	local titles = player:WaitForChild("Titles")
	local titleSelection = UIManager:GetUI("StatsMenu", "TitlesSelection")
	local scrollingFrame = UIManager:GetUI("StatsMenu", "TitleScrollingFrame")

	UIHelper:RotateGradient(scrollingFrame:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(titleSelection:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))

	local function UpdateUI(descendant, remove)
		local titleID = descendant.Name
		local titleData = TitleData.Titles[titleID]
		if not titleData then
			return
		end

		local titleSlot = scrollingFrame:FindFirstChild(titleID)
		if remove and titleSlot then
			titleSlot:Destroy()
		end

		if not titleSlot then
			titleSlot =
				UIManager:CloneUI("StatsMenu", titleID, ReplicatedStorage.Assets.UI.Title, "TitleScrollingFrame")
			UIHelper:RotateGradient(titleSlot:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))

			titleSlot.TitleName.Text = titleData.Name
			if titleData.Color then
				titleSlot:FindFirstChild("TitleName"):FindFirstChild("UIGradient").Color = titleData.Color
			end
			UIHelper:RotateGradient(titleSlot:FindFirstChild("TitleName"):FindFirstChild("UIGradient"), 16)

			for stat, buff in pairs(titleData.Buffs) do
				if buff.Percent then
					local buffText = titleSlot.TitleBuffs:FindFirstChild(stat .. "Percent")
					if not buffText then
						buffText = titleSlot.TitleBuffs.Template:Clone()
						buffText.Name = stat .. buff.Percent
						buffText.Visible = true
						buffText.Parent = titleSlot.TitleBuffs
						buffText.Text = "+" .. (buff.Percent * 100) .. "% " .. stat
					end
				end
				if buff.Flat then
					local buffText = titleSlot.TitleBuffs:FindFirstChild(stat .. "Flat")
					if not buffText then
						buffText = titleSlot.TitleBuffs.Template:Clone()
						buffText.Name = stat .. buff.Flat
						buffText.Visible = true
						buffText.Parent = titleSlot.TitleBuffs
						buffText.Text = "+" .. buff.Flat .. " " .. stat
					end
				end
			end

			local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local equipButton = titleSlot:FindFirstChild("Equip"):FindFirstChild("EquipButton")
			local unequipButton = titleSlot:FindFirstChild("Equip"):FindFirstChild("UnEquipButton")

			UIHelper:ClickEffects(equipButton)
			UIHelper:ClickEffects(unequipButton)
			UIHelper:HoverEffects(titleSlot:FindFirstChild("Equip"))
			UIHelper:RotateGradient(
				titleSlot:FindFirstChild("Equip"):FindFirstChild("RGBStroke"):FindFirstChild("UIGradient")
			)

			titleSlot:FindFirstChild("Equip").MouseEnter:Connect(function()
				TweenService
					:Create(titleSlot:FindFirstChild("Equip"), info, { ImageColor3 = Color3.fromRGB(55, 67, 122) })
					:Play()
			end)

			titleSlot:FindFirstChild("Equip").MouseLeave:Connect(function()
				TweenService
					:Create(titleSlot:FindFirstChild("Equip"), info, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
					:Play()
			end)

			---Equip Title---
			equipButton.MouseButton1Click:Connect(function()
				NetworkingService:FireToServer("EquipTitle", titleID)
			end)

			---unEquip Title---
			unequipButton.MouseButton1Click:Connect(function()
				NetworkingService:FireToServer("UnEquipTitle", titleID)
			end)
		end
	end

	for _, descendant in titles:GetDescendants() do
		UpdateUI(descendant)
	end
	titles.DescendantAdded:Connect(function(descendant)
		UpdateUI(descendant)
	end)
	titles.DescendantRemoving:Connect(function(descendant)
		UpdateUI(descendant, true)
	end)

	local function ActiveTitle()
		for _, title in titles:GetChildren() do
			local titleSlot = scrollingFrame:FindFirstChild(title.Name)
			if titleSlot then
				if titles.ActiveTitle:GetAttribute("ID") == title.Name then
					titleSlot:FindFirstChild("Equip"):FindFirstChild("EquipButton").Visible = false
					titleSlot:FindFirstChild("Equip"):FindFirstChild("UnEquipButton").Visible = true
				else
					titleSlot:FindFirstChild("Equip"):FindFirstChild("EquipButton").Visible = true
					titleSlot:FindFirstChild("Equip"):FindFirstChild("UnEquipButton").Visible = false
				end
			end
		end
	end
	ActiveTitle()
	titles.ActiveTitle:GetAttributeChangedSignal("ID"):Connect(ActiveTitle)
end

function StatsMenuController:Armory()
	local player = Players.LocalPlayer
	local inventory = player:WaitForChild("Inventory")
	local equipped = player:WaitForChild("Equipped")
	local armory = UIManager:GetUI("StatsMenu", "Armory")
	local armoryList = armory:FindFirstChild("ArmoryList")
	local armoryInfo = armory:FindFirstChild("ArmoryInfo")
	local info = TweenInfo.new(0.0625, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

	UIHelper:RotateGradient(armoryInfo:FindFirstChild("InnerStroke"):FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(armoryInfo:FindFirstChild("OuterStroke"):FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(armoryList:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(armoryList:FindFirstChild("Search"):FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))

	local itemFrame = armoryList:FindFirstChild("ArmoryScrollingFrame")
	local infoImage = armoryInfo.ItemImage
	local infoName = armoryInfo.ItemName
	local infoType = armoryInfo.ItemType
	local infoRarity = armoryInfo.ItemRarity
	local infoDescription = armoryInfo.Description
	local abiltiesFrame = armoryInfo:FindFirstChild("Abilties")
	local statsFrame = armoryInfo:FindFirstChild("Stats")
	local infoMastery = armoryInfo.ItemMastery
	local equipIcon = armoryInfo:FindFirstChild("Equip")
	local equipButton = equipIcon:FindFirstChild("EquipButton")
	local unequipButton = equipIcon:FindFirstChild("UnEquipButton")

	for _, abilitySlot in abiltiesFrame:GetChildren() do
		if abilitySlot:IsA("Frame") then
			UIHelper:RotateGradient(
				abilitySlot:FindFirstChild("AbilityIcon"):FindFirstChild("RGBStroke"):FindFirstChild("UIGradient")
			)
		end
	end

	for _, statSlot in statsFrame:GetChildren() do
		if statSlot:IsA("Frame") then
			UIHelper:RotateGradient(statSlot:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))
		end
	end

	UIHelper:RotateGradient(equipIcon:FindFirstChild("RGBStroke"):FindFirstChild("UIGradient"))
	UIHelper:HoverEffects(equipIcon)
	UIHelper:ClickEffects(equipButton)
	UIHelper:ClickEffects(unequipButton)
	equipIcon.MouseEnter:Connect(function()
		TweenService:Create(equipIcon, info, { ImageColor3 = Color3.fromRGB(55, 67, 122) }):Play()
	end)

	equipIcon.MouseLeave:Connect(function()
		TweenService:Create(equipIcon, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)

	equipButton.MouseButton1Click:Connect(function()
		local itemID = armoryInfo:GetAttribute("ItemID")
		NetworkingService:FireToServer("EquipItem", itemID)
		TweenService:Create(equipButton, info, { TextTransparency = 1 }):Play()
		TweenService:Create(unequipButton, info, { TextTransparency = 0 }):Play()
		task.wait(0.0625)
		equipButton.Visible = false
		unequipButton.Visible = true
	end)

	unequipButton.MouseButton1Click:Connect(function()
		local itemID = armoryInfo:GetAttribute("ItemID")
		NetworkingService:FireToServer("UnequipItem", itemID)

		TweenService:Create(equipButton, info, { TextTransparency = 0 }):Play()
		TweenService:Create(unequipButton, info, { TextTransparency = 1 }):Play()
		task.wait(0.0625)
		equipButton.Visible = true
		unequipButton.Visible = false
	end)

	equipped.ChildAdded:Connect(function(child)
		local icon = itemFrame:FindFirstChild(child:GetAttribute("Equipped"))
		if icon then
			icon:FindFirstChild("EquippedIcon").Visible = true
		end
	end)

	equipped.ChildRemoved:Connect(function(child)
		local icon = itemFrame:FindFirstChild(child:GetAttribute("Equipped"))
		if icon then
			icon:FindFirstChild("EquippedIcon").Visible = false
		end
	end)

	local IconSelected = nil
	local PrevIconSelected = nil

	for _, itemSlot in itemFrame:GetChildren() do
		if itemSlot:IsA("ImageButton") then
			itemSlot:Destroy()
		end
	end
	local function UpdateUI(descendant: Instance, remove)
		armoryInfo.Visible = false
		local itemID = descendant.Name

		if not string.find(itemID, "weapon") and not string.find(itemID, "armor") then
			print(itemID)
			return
		end
		local itemData = ItemDataBase:GetItemData(itemID)

		local itemSlot = itemFrame:FindFirstChild(itemID)
		if itemSlot and remove then
			itemSlot:Destroy()
			return
		end

		if not itemSlot then
			itemSlot = UIManager:CloneUI(
				"StatsMenu",
				itemID,
				ReplicatedStorage.Assets.UI.Icons[itemData.Rarity .. "Item"],
				"ArmoryScrollingFrame"
			)
			UIHelper:ClickEffects(itemSlot)
			UIHelper:HoverEffects(itemSlot)
			local border = itemSlot:FindFirstChild("Border")
			UIHelper:RotateGradient(border:FindFirstChild("UIGradient"))

			local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			itemSlot.MouseEnter:Connect(function()
				itemSlot.ImageColor3 = Color3.fromHex("#eeeeee")
				if IconSelected ~= itemSlot then
					TweenService:Create(border, info, { ImageColor3 = Color3.fromRGB(71, 88, 158) }):Play()
				end
			end)

			itemSlot.MouseLeave:Connect(function()
				itemSlot.ImageColor3 = Color3.fromHex("#ffffff")
				if IconSelected ~= itemSlot then
					TweenService:Create(border, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				end
			end)

			itemSlot.MouseButton1Click:Connect(function()
				PrevIconSelected = IconSelected
				IconSelected = itemSlot
				if IconSelected ~= nil then
					TweenService:Create(IconSelected.Border, info, { ImageColor3 = Color3.fromRGB(114, 142, 255) })
						:Play()
				end
				if PrevIconSelected ~= nil and PrevIconSelected ~= IconSelected then
					TweenService:Create(PrevIconSelected.Border, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
						:Play()
				end

				---Info Setup---
				for _, ability in abiltiesFrame:GetChildren() do
					if ability:IsA("Frame") then
						local abilityLetter = ability.AbilityIcon.AbilityLetter.Text
						if itemData.Abilities then
							local abilityData = AbilityData:GetAbilityData(itemData.Abilities[abilityLetter])
							if not abilityData then
								ability.Visible = false
							else
								ability.Visible = true
								ability.AbilityMastery.Text = abilityData.AbilityMastery
								ability.AbilityName.Text = abilityData.AbilityName
							end
						end
					end
				end

				for _, Stat in statsFrame:GetChildren() do
					if not Stat:IsA("Frame") then
						continue
					end
					local statCatagory: TextLabel = Stat.StatCatagory.Text
					local statNumber: TextLabel = Stat.StatNumber
					if itemData[statCatagory] == nil then
						if itemData.Buffs then
							if itemData.Buffs[statCatagory] == nil then
								Stat.Visible = false
								statNumber.Text = ""
							else
								Stat.Visible = true
								if itemData.Buffs[statCatagory].Percent then
									statNumber.Text = "+" .. (itemData.Buffs[statCatagory].Percent * 100) .. "%"
								else
									statNumber.Text = "+" .. itemData.Buffs[statCatagory].Flat
								end
							end
						else
							Stat.Visible = false
							statNumber.Text = ""
						end
					else
						Stat.Visible = true
						if Stat.Name == "CriticalRate" or Stat.Name == "CriticalDamage" then
							statNumber.Text = (itemData[statCatagory] * 100) .. "%"
						else
							statNumber.Text = itemData[statCatagory]
						end
					end
				end

				armoryInfo:SetAttribute("ItemName", itemData.Name)
				armoryInfo:SetAttribute("ItemID", itemID)
				infoImage.Image = itemData.Icon
				infoName.Text = itemData.Name
				infoName.TextColor3 = Color3.fromHex(RarityData[itemData.Rarity].Color)
				infoType.Text = itemData.Type
				infoRarity.Text = itemData.Rarity
				infoRarity.TextColor3 = Color3.fromHex(RarityData[itemData.Rarity].Color)
				armoryInfo.Visible = true
				infoDescription.Text = itemData.Description
				equipIcon.Visible = true
				statsFrame.Visible = true

				---If Item Is A Weapon---
				if string.find(itemID, "weapon") then
					infoMastery.Text = "Mastery: " .. tostring(descendant:GetAttribute("Mastery"))
					infoMastery.Visible = true
					abiltiesFrame.Visible = true
					---If Item Is An Armor
				elseif string.find(itemID, "armor") then
					infoMastery.Visible = false
					abiltiesFrame.Visible = false
				end

				if
					equipped:FindFirstChild(itemData.Type)
					and equipped:FindFirstChild(itemData.Type):GetAttribute("Equipped") == itemID
				then
					TweenService:Create(equipButton, info, { TextTransparency = 1 }):Play()
					TweenService:Create(unequipButton, info, { TextTransparency = 0 }):Play()
					equipButton.Visible = false
					unequipButton.Visible = true
				else
					TweenService:Create(equipButton, info, { TextTransparency = 0 }):Play()
					TweenService:Create(unequipButton, info, { TextTransparency = 1 }):Play()
					equipButton.Visible = true
					unequipButton.Visible = false
				end
			end)
		end
		local equippedIcon = itemSlot:FindFirstChild("EquippedIcon")
		itemSlot.NameText.Text = itemData.Name
		itemSlot.Icon.Image = itemData.Icon
		if itemSlot:FindFirstChild("OwnedAmount") then
			itemSlot:FindFirstChild("OwnedAmount"):Destroy()
		end
		if
			equipped:FindFirstChild(itemData.Type)
			and equipped:FindFirstChild(itemData.Type):GetAttribute("Equipped") == itemID
		then
			equippedIcon.Visible = true
		else
			equippedIcon.Visible = false
		end
	end

	for _, descendant in inventory:GetDescendants() do
		descendant.AttributeChanged:Connect(function()
			UpdateUI(descendant)
		end)
		UpdateUI(descendant)
	end

	inventory.DescendantAdded:Connect(function(descendant)
		UpdateUI(descendant)
	end)

	inventory.DescendantRemoving:Connect(function(descendant)
		UpdateUI(descendant, true)
	end)

	---Search---
	local searchBox = UIManager:GetUI("StatsMenu", "SearchBox")
	UIHelper:RotateGradient(searchBox.Parent:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(searchBox.Parent:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = searchBox.Text:lower()

		for _, icon in itemFrame:GetChildren() do
			if icon:IsA("ImageButton") then
				local itemName = icon.NameText.Text:lower()

				if text == "" then
					icon.Visible = true
				else
					icon.Visible = false

					for word in string.gmatch(itemName, "%S+") do
						if string.sub(word, 1, #text) == text then
							icon.Visible = true
							break
						end
					end
				end
			end
		end
	end)
end

function StatsMenuController:RandomGradients()
	local texture = UIManager:GetUI("StatsMenu", "Texture")
	UIHelper:RotateGradient(texture:FindFirstChild("UIGradient"))
end

return StatsMenuController
