local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local EXPBar = require(ReplicatedStorage.Modules.Client.UI.Components.EXPBar)
local HealthBar = require(ReplicatedStorage.Modules.Client.UI.Components.HealthBar)
local ManaBar = require(ReplicatedStorage.Modules.Client.UI.Components.ManaBar)
local ReturnButton = require(ReplicatedStorage.Modules.Client.UI.Components.ReturnButton)
local StaminaBar = require(ReplicatedStorage.Modules.Client.UI.Components.StaminaBar)
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local TitleData = require(ReplicatedStorage.Modules.Data.TitleData)
local StateChecker = require(ReplicatedStorage.Modules.Helpers.StateChecker)
local UIHelper = require(game.ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(game.ReplicatedStorage.Modules.Client.UI.UIManager)

local MainMenuController = {}

function MainMenuController:Main()
	local MainMenu = UIManager:GetUI("MainMenu", "MainMenu")
	for _, button: ImageButton in MainMenu:FindFirstChild("Main"):GetChildren() do
		if button:IsA("ImageButton") then
			UIHelper:ClickEffects(button)
			UIHelper:HoverEffects(button)

			local name = button.Name:split("Button")[1]
			local frame = UIManager:GetUI(name .. "Menu", name .. "Menu")

			if not frame then
				warn("Frame For:", button.Name, "Does't Exist")
				return
			end
			button.MouseButton1Click:Connect(function()
				UIManager:SetActiveScreen(frame.Parent.Name)
			end)
		end
	end
end

function MainMenuController:BottomBar()
	local bottomBar = UIManager:GetUI("MainMenu", "BottomBar")

	for _, button: ImageButton in bottomBar:GetChildren() do
		if button:IsA("ImageButton") then
			UIHelper:ClickEffects(button)
			UIHelper:HoverEffects(button)

			local name = button.Name:split("Button")[1]
			local frame = UIManager:GetUI(name .. "Menu", name .. "Menu")

			if not frame then
				warn("Frame For:", button.Name, "Does't Exist")
				return
			end

			button.MouseButton1Click:Connect(function()
				UIManager:SetActiveScreen(frame.Parent.Name)
			end)
		end
	end
end

function MainMenuController:Overview()
	local Player = game:GetService("Players").LocalPlayer
	---Health,Mana,EXP---
	HealthBar("MainMenu")
	ManaBar("MainMenu")
	EXPBar("MainMenu")
	StaminaBar("MainMenu")

	---Title---
	local activeTitle: StringValue = Player:WaitForChild("Titles"):FindFirstChild("ActiveTitle")
	local titleFrame = UIManager:GetUI("MainMenu", "Title")

	local function Title()
		local titleData = TitleData.Titles[activeTitle:GetAttribute("ID")]
		if not titleData then
			titleFrame.TextLabel.Text = "No Title"
			titleFrame:FindFirstChild("UIGradient").Color = ColorSequence.new(Color3.fromRGB(76, 76, 76))
			titleFrame:FindFirstChild("TextLabel"):FindFirstChild("UIGradient").Color =
				ColorSequence.new(Color3.fromRGB(255, 255, 255))
		else
			titleFrame.TextLabel.Text = titleData.Name
			if titleData.Color then
				titleFrame:FindFirstChild("UIGradient").Color = titleData.Color
				titleFrame:FindFirstChild("TextLabel"):FindFirstChild("UIGradient").Color = titleData.Color
			else
				titleFrame:FindFirstChild("UIGradient").Color = ColorSequence.new(Color3.fromRGB(76, 76, 76))
				titleFrame:FindFirstChild("TextLabel"):FindFirstChild("UIGradient").Color =
					ColorSequence.new(Color3.fromRGB(255, 255, 255))
			end
		end
	end
	Title()
	activeTitle.AttributeChanged:Connect(Title)

	---Level---
	local levelNumber = UIManager:GetUI("MainMenu", "Level")
	local CurrentLevel: Instance = Player:WaitForChild("Level").CurrentLevel

	levelNumber.Text = CurrentLevel:GetAttribute("Amount")
	CurrentLevel:GetAttributeChangedSignal("Amount"):Connect(function()
		levelNumber.Text = CurrentLevel:GetAttribute("Amount")
	end)

	---Player Name---
	local PlayerNameText = UIManager:GetUI("MainMenu", "NameText")
	PlayerNameText.Text = Player.Name

	local playerStats = Player:WaitForChild("Stats")
	local statsFrame = UIManager:GetUI("MainMenu", "Stats")

	local function TotalStatsRefresh(Stat)
		local finalStat = Stat:GetAttribute("Final")
		local statBox = statsFrame:FindFirstChild(Stat.Name)
		if statBox then
			local statsNumber = statBox:FindFirstChild("TextLabel")
			statsNumber.Text = string.upper(Stat.Name:sub(1, 3)) .. " " .. finalStat
		end
	end
	for _, Stat in playerStats.MainStats:GetChildren() do
		TotalStatsRefresh(Stat)
		Stat.AttributeChanged:Connect(function()
			TotalStatsRefresh(Stat)
		end)
	end

	local Equipment = {}

	local folder = UIManager:GetUI("MainMenu", "Equipment")
	for _, box in folder:GetChildren() do
		if box:IsA("ImageLabel") then
			UIHelper:HoverEffects(box)
			Equipment[box.Name] = box
		end
	end

	local equipped = Player:WaitForChild("Equipped")
	local function UpdateEquipment()
		for type, box in pairs(Equipment) do
			box.ImageTransparency = 0
			if box:FindFirstChildWhichIsA("ImageButton") then
				box:FindFirstChildWhichIsA("ImageButton"):Destroy()
			end
			if equipped:FindFirstChild(type) and equipped:FindFirstChild(type):GetAttribute("Equipped") then
				local itemID = equipped:FindFirstChild(type):GetAttribute("Equipped")
				local itemData = ItemDataBase:GetItemData(itemID)
				if not itemData then
					continue
				end

				local icon = UIManager:CloneUI(
					"MainMenu",
					itemID,
					ReplicatedStorage.Assets.UI.Icons:FindFirstChild(itemData.Rarity .. "Item"),
					box.Name
				)
				icon:FindFirstChild("OwnedAmount"):Destroy()
				icon:FindFirstChild("NameText"):Destroy()
				icon.Name = itemID
				icon.Icon.Image = itemData.Icon
				icon.Parent = box

				box.ImageTransparency = 0
			end
		end
	end
	UpdateEquipment()
	equipped.ChildRemoved:Connect(UpdateEquipment)
	equipped.ChildAdded:Connect(UpdateEquipment)

	local char = Player.Character or Player.CharacterAdded:Wait()
	local stateFolder = char:WaitForChild("State")

	local statusEffectsFrame = UIManager:GetUI("MainMenu", "StatusEffects")
	local function UpdateStatusEffects()
		for _, statusEffectIcon in statusEffectsFrame:GetChildren() do
			if not statusEffectIcon:IsA("ImageLabel") then
				continue
			end
			if StateChecker:CheckState(char, statusEffectIcon.Name) then
				statusEffectIcon.Visible = true
				local state = stateFolder:FindFirstChild(statusEffectIcon.Name)
				if state:GetAttribute("Duration") then
					state:GetAttributeChangedSignal("Duration"):Connect(function()
						statusEffectIcon.Duration.Text = math.floor(state:GetAttribute("Duration"))
					end)
					statusEffectIcon.Duration.Text = math.floor(state:GetAttribute("Duration"))
				end
			else
				statusEffectIcon.Visible = false
			end
		end
	end
	UpdateStatusEffects()
	stateFolder.ChildAdded:Connect(UpdateStatusEffects)
	stateFolder.ChildRemoved:Connect(UpdateStatusEffects)
end

function MainMenuController:TopBar()
	ReturnButton("MainMenu")
end

function MainMenuController:MainMenu()
	------M to open MainMenu------
	UserInputService.InputBegan:Connect(function(inp, proc)
		if proc then
			return
		end
		if inp.KeyCode == Enum.KeyCode.M then
			if UIManager.ActiveScreen == "MainMenu" then
				UIManager:SetActiveScreen("HUD")
			else
				UIManager:SetActiveScreen("MainMenu")
			end
		end
	end)
end

function MainMenuController:Titles()
	
end

return MainMenuController
