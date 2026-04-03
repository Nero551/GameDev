local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local QuestData = require(ReplicatedStorage.Modules.Data.QuestData)
local AbilityData = require(game.ReplicatedStorage.Modules.Data.AbilityData)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local UIHelper = require(game.ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(game.ReplicatedStorage.Modules.Client.UI.UIManager)
local StatusEffectsData = require(ReplicatedStorage.Modules.Data.StatusEffectsData)

local HUDController = {}

local player = Players.LocalPlayer

function HUDController:Health()
	local HealthBar = require(ReplicatedStorage.Modules.Client.UI.Components.HealthBar)
	HealthBar("HUD")
end

function HUDController:Mana()
	local ManaBar = require(ReplicatedStorage.Modules.Client.UI.Components.ManaBar)
	ManaBar("HUD")
end

function HUDController:EXP()
	local EXPBar = require(ReplicatedStorage.Modules.Client.UI.Components.EXPBar)
	EXPBar("HUD")
end

function HUDController:Stamina()
	local StaminaBar = require(ReplicatedStorage.Modules.Client.UI.Components.StaminaBar)
	StaminaBar("HUD")
end

function HUDController:Flashstep()
	local char = player.Character or player.CharacterAdded:Wait()
	local chargeText = UIManager:GetUI("HUD", "FlashStepCharge")
	local function UpdateFlashstep()
		local currentFlashStep = char:GetAttribute("FlashStep_CurrentFlashStep")
		local maxFlashStep = char:GetAttribute("FlashStep_MaxFlashStep")
		if currentFlashStep and maxFlashStep then
			chargeText.Text = "Flashstep " .. currentFlashStep .. " / " .. maxFlashStep
		end
	end
	UpdateFlashstep()
	char:GetAttributeChangedSignal("FlashStep_CurrentFlashStep"):Connect(UpdateFlashstep)
	char:GetAttributeChangedSignal("FlashStep_MaxFlashStep"):Connect(UpdateFlashstep)
end

function HUDController:Tools()
	local char = player.Character or player.CharacterAdded:Wait()
	local equipped = player:WaitForChild("Equipped")
	local Keys = {
		["Melee"] = "One",
		["Sword"] = "Two",
		["Grimiore"] = "Three",
		["RiftBorn"] = "Four",
	}

	local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function UpdateToolSelection()
		local inHand = char:GetAttribute("InHand")

		for _, slot in UIManager:GetUI("HUD", "Tools"):GetChildren() do
			if slot:IsA("ImageButton") then
				local type = equipped:FindFirstChild(slot.Name:split("Slot")[1])
				TweenService:Create(slot.Border, info, { ImageColor3 = Color3.fromRGB(116, 116, 116) }):Play()

				if type and type:GetAttribute("Equipped") == inHand then
					TweenService:Create(slot.Border, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
				end
			end
		end
	end

	local function UpdateTools()
		for _, slot in UIManager:GetUI("HUD", "Tools"):GetChildren() do
			if slot:IsA("ImageButton") then
				slot.Visible = false
			end
		end
		for _, child in equipped:GetChildren() do
			local itemID = child:GetAttribute("Equipped")
			if string.find(itemID, "weapon") then
				local itemData = ItemDataBase:GetItemData(itemID)
				local slot: ImageButton = UIManager:GetUI("HUD", itemData.Type .. "Slot")
				if slot then
					local icon: ImageLabel = UIManager:GetUI("HUD", itemData.Type .. "Icon")
					slot.Visible = true
					icon.Image = itemData.Icon
				end
			end
		end

		UpdateToolSelection()
	end

	for _, slot in UIManager:GetUI("HUD", "Tools"):GetChildren() do
		if slot:IsA("ImageButton") then
			UIHelper:RotateGradient(slot.Border.UIGradient)

			slot.MouseButton1Click:Connect(function()
				local type = equipped:FindFirstChild(slot.Name:split("Slot")[1])
				if type then
					local itemID = type:GetAttribute("Equipped")
					if char:GetAttribute("InHand") == itemID then
						NetworkingService:FireToServer("RequestRemoveFromHand", itemID)
					else
						if char:GetAttribute("InHand") ~= "" then
							NetworkingService:FireToServer("RequestRemoveFromHand", itemID)
						end
						NetworkingService:FireToServer("RequestPutInHand", itemID)
					end
				end
			end)
		end
	end

	UserInputService.InputBegan:Connect(function(inp, proc)
		if proc then
			return
		end

		for _, slot in UIManager:GetUI("HUD", "Tools"):GetChildren() do
			if slot:IsA("ImageButton") then
				local type = equipped:FindFirstChild(slot.Name:split("Slot")[1])
				if type and inp.KeyCode.Name == Keys[type.Name] then
					local itemID = type:GetAttribute("Equipped")
					if char:GetAttribute("InHand") == itemID then
						NetworkingService:FireToServer("RequestRemoveFromHand", itemID)
					else
						if char:GetAttribute("InHand") ~= "" then
							NetworkingService:FireToServer("RequestRemoveFromHand", itemID)
						end
						NetworkingService:FireToServer("RequestPutInHand", itemID)
					end
				end
			end
		end
	end)

	UpdateTools()
	UpdateToolSelection()
	equipped.ChildAdded:Connect(UpdateTools)
	equipped.ChildRemoved:Connect(UpdateTools)
	char:GetAttributeChangedSignal("InHand"):Connect(UpdateToolSelection)
end

function HUDController:Abilities()
	local char = player.Character or player.CharacterAdded:Wait()
	local bars = {}
	local abilityUI = UIManager:GetUI("HUD", "AbilityFrame")

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- cache UI
	for _, ui in abilityUI:GetChildren() do
		if ui:IsA("ImageLabel") then
			local innerStroke = ui:FindFirstChild("InnerStroke")
			UIHelper:RotateGradient(innerStroke:FindFirstChild("UIGradient"))
			local abilityKey = ui.Name:split("AbilityBar")[2]
			bars[abilityKey] = {
				bar = ui,
				cdBar = ui:WaitForChild("CDBar"),
				nameLabel = ui:WaitForChild("AbilityName"),
				cdActive = false,
				cdText = ui:WaitForChild("CDText"),
				cdEndTime = nil,
				abilityLetter = ui:WaitForChild("AbilityLetter"),
				innerStroke = innerStroke,
			}

			ui.Visible = false
			bars[abilityKey].cdBar.Visible = false
			bars[abilityKey].cdBar.Size = UDim2.fromScale(-0.97, 0.87)
		end
	end

	-- update loop
	RunService.RenderStepped:Connect(function()
		local tool = char:FindFirstChildWhichIsA("Tool")
		if not tool then
			for _, bar in pairs(bars) do
				bar.bar.Visible = false
			end
			return
		end

		for abilityKey, data in pairs(bars) do
			local itemData = ItemDataBase:GetItemData(tool:GetAttribute("ID"))
			if not itemData.Abilities then
				return
			end
			local abilityData = AbilityData:GetAbilityData(itemData.Abilties[abilityKey])
			local weaponData = ItemDataBase:GetItemData(tool.Name)
			if not abilityData then
				data.bar.Visible = false
				continue
			end

			data.bar.Visible = true
			data.nameLabel.Text = abilityData.AbilityName
			local cdStateName = "Ability" .. abilityKey .. " Cooldown"
			local onCooldown = StateChecker:CheckState(char, cdStateName)
			if onCooldown and data.cdActive and data.cdEndTime then
				local remaining = math.max(0, data.cdEndTime - time())
				data.cdText.Text = string.format("%.1f", remaining)
			end

			if onCooldown and not data.cdActive then
				data.cdActive = true
				data.cdBar.Visible = true
				data.cdEndTime = time() + abilityData.AbilityCooldown

				local tween = TweenService:Create(
					data.cdBar,
					TweenInfo.new(abilityData.AbilityCooldown, Enum.EasingStyle.Linear),
					{ Size = UDim2.fromScale(0, 0.87) }
				)

				tween:Play()
				tween.Completed:Once(function()
					data.cdActive = false
					data.cdBar.Visible = false
					data.cdBar.Size = UDim2.fromScale(-0.97, 0.87)
					data.cdText.Text = ""
					data.cdEndTime = nil
				end)
			end

			---Looks BS---
			if weaponData.Type == "Sword" then
				TweenService:Create(data.nameLabel, info, { TextColor3 = Color3.fromHex("#ffe134") }):Play()
				TweenService:Create(data.abilityLetter, info, { TextColor3 = Color3.fromHex("#ffe134") }):Play()
				TweenService:Create(data.innerStroke, info, { ImageColor3 = Color3.fromHex("#ffe134") }):Play()
			elseif weaponData.Type == "Melee" then
				TweenService:Create(data.nameLabel, info, { TextColor3 = Color3.fromHex("#ff2c30") }):Play()
				TweenService:Create(data.abilityLetter, info, { TextColor3 = Color3.fromHex("#ff2c30") }):Play()
				TweenService:Create(data.innerStroke, info, { ImageColor3 = Color3.fromHex("#ff2c30") }):Play()
			elseif weaponData.Type == "Grimiore" then
				TweenService:Create(data.nameLabel, info, { TextColor3 = Color3.fromHex("#1cd9ff") }):Play()
				TweenService:Create(data.abilityLetter, info, { TextColor3 = Color3.fromHex("#1cd9ff") }):Play()
				TweenService:Create(data.innerStroke, info, { ImageColor3 = Color3.fromHex("#1cd9ff") }):Play()
			elseif weaponData.Type == "RiftBorn" then
				TweenService:Create(data.nameLabel, info, { TextColor3 = Color3.fromHex("#b520ff") }):Play()
				TweenService:Create(data.abilityLetter, info, { TextColor3 = Color3.fromHex("#b520ff") }):Play()
				TweenService:Create(data.innerStroke, info, { ImageColor3 = Color3.fromHex("#b520ff") }):Play()
			end
		end
	end)
end

function HUDController:InCombat()
	local char = player.Character or player.CharacterAdded:Wait()
	local stateFolder = char:WaitForChild("State")
	local inCombatText = UIManager:GetUI("HUD", "InCombatText")

	local function UpdateCombatText()
		if StateChecker:CheckState(char, "In Combat") then
			inCombatText.Visible = true
		else
			inCombatText.Visible = false
		end
	end
	stateFolder.ChildAdded:Connect(UpdateCombatText)

	stateFolder.ChildRemoved:Connect(UpdateCombatText)
end

function HUDController:StatusEffects()
	local char = player.Character or player.CharacterAdded:Wait()
	local stateFolder = char:WaitForChild("State")
	local screen = UIManager.Screens.HUD
	local statusEffectsFrame = screen.StatusEffectsFrame or screen.AilmentsFrame
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

function HUDController:Currencies()
	local currencies = player:WaitForChild("Currencies")
	for _, type in currencies:GetChildren() do
		UIManager:GetUI("HUD", type.Name .. "Number").Text = type:GetAttribute("Amount")
		type:GetAttributeChangedSignal("Amount"):Connect(function()
			UIManager:GetUI("HUD", type.Name .. "Number").Text = type:GetAttribute("Amount")
		end)
	end
end

function HUDController:Level()
	local level: ImageButton = UIManager:GetUI("HUD", "Level")
	local innerStroke = level:FindFirstChild("InnerStroke")
	local outerStroke = level:FindFirstChild("OuterStroke")

	UIHelper:RotateGradient(innerStroke:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(outerStroke:FindFirstChild("UIGradient"))

	local levelNumber = UIManager:GetUI("HUD", "LevelNumber")
	local CurrentLevel: Instance = player:WaitForChild("Level").CurrentLevel

	levelNumber.Text = CurrentLevel:GetAttribute("Amount")
	CurrentLevel:GetAttributeChangedSignal("Amount"):Connect(function()
		levelNumber.Text = CurrentLevel:GetAttribute("Amount")
	end)
end

function HUDController:Dialogue()
	local DialogueFrame = UIManager:GetUI("HUD", "DialogueFrame")

	local stroke = DialogueFrame:FindFirstChild("UIStroke")
	UIHelper:RotateGradient(stroke:FindFirstChild("UIGradient"))

	local DialogueText = DialogueFrame.DialogueText
	local SpeakerName = DialogueFrame.SpeakerName
	local Texture = DialogueFrame.Texture

	local skipLine = false
	local canClick = true

	Texture.MouseButton1Click:Connect(function()
		if skipLine == true and canClick == true then
			NetworkingService:FireToServer("ContinueDialogue", player)
		end
		skipLine = true
	end)

	local function PlayLine(speaker, line)
		DialogueFrame.Visible = true
		SpeakerName.Text = speaker
		DialogueText.Text = ""

		skipLine = false
		local i = 0
		local length = #line

		while i < length do
			i += 1
			DialogueText.Text = string.sub(line, 1, i)
			ReplicatedStorage.Assets.Shared.Sounds.DialogueSound:Play()
			if skipLine then
				DialogueText.Text = line
				break
			end
			task.wait(0.03)
		end
		skipLine = true
	end

	NetworkingService:OnClientEvent("ShowDialogue", function(speaker, text, options, ended)
		if ended then
			DialogueFrame.Visible = false
			SpeakerName.Text = ""
			DialogueText.Text = ""
			return
		end

		for _, optionButton in DialogueFrame.OptionFrame:GetChildren() do
			if optionButton:IsA("ImageButton") then
				optionButton:Destroy()
			end
		end

		PlayLine(speaker, text)

		if options then
			for option, optioninfo in pairs(options) do
				local optionButton =
					UIManager:CloneUI("HUD", option, ReplicatedStorage.Assets.UI.DialogueOption, "OptionFrame")
				UIHelper:RotateGradient(optionButton:FindFirstChild("UIGradient"))
				UIHelper:RotateGradient(optionButton:FindFirstChild("RGBStroke"):FindFirstChild("UIGradient"))
				optionButton.Text.Text = optioninfo.Text
				optionButton.MouseButton1Click:Connect(function()
					NetworkingService:FireToServer("SelectDialogueOption", option)
				end)
			end
			canClick = false
		else
			canClick = true
		end
	end)
end

function HUDController:TrackedQuest()
	local player = Players.LocalPlayer
	local Quests = player:WaitForChild("Quests")
	local trackedQuest = Quests:FindFirstChild("TrackedQuest")
	local trackedQuestFrame = UIManager:GetUI("HUD", "TrackedQuestFrame")
	local trackQuestButton = trackedQuestFrame:FindFirstChild("TrackQuestButton")
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local innerStroke = trackedQuestFrame:FindFirstChild("InnerStroke")
	local outerStroke = trackedQuestFrame:FindFirstChild("OuterStroke")
	UIHelper:RotateGradient(innerStroke:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(outerStroke:FindFirstChild("UIGradient"))

	trackQuestButton.MouseButton1Click:Connect(function()
		NetworkingService:FireToServer("TrackQuest", trackedQuest:GetAttribute("ID"))
	end)
	UIHelper:ClickEffects(trackQuestButton)
	UIHelper:HoverEffects(trackQuestButton)

	local function UpdateTracked()
		for _, objective in trackedQuestFrame.TrackedQuestProgress:GetChildren() do
			if objective:IsA("Frame") then
				objective:Destroy()
			end
		end

		local trackedQuestID = trackedQuest:GetAttribute("ID")
		if trackedQuestID then
			local trackedQuestData = QuestData.Quests[trackedQuestID]
			if trackedQuestData then
				trackedQuestFrame.Visible = true
				trackedQuestFrame:FindFirstChild("TrackedQuestName").Text = trackedQuestData.Name

				for _, objective in Quests:FindFirstChild("ActiveQuests"):FindFirstChild(trackedQuestID):GetChildren() do
					local function UpdateObjectives()
						local objectiveNumber = objective.Name
						local objectiveFrame = trackedQuestFrame.TrackedQuestProgress:FindFirstChild(objectiveNumber)
						if not objectiveFrame then
							objectiveFrame = UIManager:CloneUI(
								"HUD",
								objectiveNumber,
								ReplicatedStorage.Assets.UI.Quest.QuestProgress.ObjectiveTemplate,
								"TrackedQuestProgress"
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
					UpdateObjectives()
					local conn
					if not conn then
						conn = objective.AttributeChanged:Connect(UpdateObjectives)
					end
				end
			else
				trackedQuestFrame.Visible = false
			end
		end
	end
	UpdateTracked()
	trackedQuest:GetAttributeChangedSignal("ID"):Connect(UpdateTracked)
end

function HUDController:Time()
	local timeText = UIManager:GetUI("HUD", "Time")
	timeText.Text = Lighting.TimeOfDay

	Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
		local splits = Lighting.TimeOfDay:split(":")
		local hour = tonumber(splits[1])
		local minute = tonumber(splits[2])

		local period = "AM"
		if hour > 12 then
			hour = hour - 12
			period = "PM"
		end

		if hour < 10 then
			hour = "0" .. hour
		end

		if minute < 10 then
			minute = "0" .. minute
		end

		local time = hour .. ":" .. minute .. " " .. period
		timeText.Text = time
	end)
end

function HUDController:DamageCounter()
	local damageFrame = UIManager:GetUI("HUD", "DamageFrame")
	local damageText = damageFrame.DamageNumber
	local comboDuration = damageFrame.ComboDuration
	local ExtraText = damageFrame.ExtraText
	local ExtraImage = damageFrame.ExtraImage

	damageFrame.Visible = false
	damageText.Text = ""
	comboDuration.Visible = false
	ExtraText.Visible = false
	ExtraImage.Visible = false

	local BASE_SIZE = damageText.Size
	local BASE_ExtraText_SIZE = ExtraText.Size
	local BASE_ExtraImage_SIZE = ExtraImage.Size

	local function DefualtTween()
		ExtraText.Visible = false
		ExtraImage.Visible = false

		local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local color = Color3.fromRGB(176, 176, 176)

		TweenService:Create(comboDuration, info, { BackgroundColor3 = color }):Play()

		TweenService:Create(damageText, info, {
			TextColor3 = color,
			Size = BASE_SIZE + UDim2.fromScale(0.05, 0.05),
		}):Play()

		task.delay(0.25, function()
			local shrinkTween =
				TweenService:Create(damageText, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = BASE_SIZE - UDim2.fromScale(0.05, 0.05),
				})
			shrinkTween:Play()
		end)
	end

	local function BlockedTween()
		ExtraText.Text = "BLOCKED"
		ExtraImage.Visible = false
		ExtraText.Visible = true
		local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local color = Color3.fromRGB(41, 41, 255)

		TweenService:Create(ExtraText, info, { TextColor3 = color }):Play()

		TweenService:Create(comboDuration, info, { BackgroundColor3 = color }):Play()

		TweenService:Create(damageText, info, {
			TextColor3 = color,
			Size = BASE_SIZE + UDim2.fromScale(0.05, 0.05),
		}):Play()

		task.delay(0.25, function()
			local shrinkTween =
				TweenService:Create(damageText, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = BASE_SIZE - UDim2.fromScale(0.05, 0.05),
				})
			shrinkTween:Play()
		end)
	end

	local function BlackFlashTween()
		ExtraText.Text = "BLACK FLASH"
		ExtraImage.Visible = false
		ExtraText.Visible = true
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local color = Color3.fromRGB(255, 24, 28)

		TweenService:Create(ExtraText, info, { TextColor3 = color }):Play()

		TweenService:Create(comboDuration, info, { BackgroundColor3 = color }):Play()

		TweenService:Create(ExtraText, info, {
			Size = BASE_ExtraText_SIZE + UDim2.fromScale(0.1, 0.1),
			Rotation = 5,
		}):Play()

		TweenService:Create(damageText, info, {
			TextColor3 = color,
			Size = BASE_SIZE + UDim2.fromScale(0.1, 0.1),
			Rotation = 5,
		}):Play()

		task.delay(0.25, function()
			local shrinkTween =
				TweenService:Create(damageText, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Size = BASE_SIZE - UDim2.fromScale(0.1, 0.1),
					Rotation = 0,
				})
			local shrinkCriticalTween =
				TweenService:Create(ExtraText, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Size = BASE_ExtraText_SIZE - UDim2.fromScale(0.1, 0.1),
					Rotation = 0,
				})
			shrinkTween:Play()
			shrinkCriticalTween:Play()
		end)
	end

	local function CriticalTween()
		ExtraText.Text = "CRITICAL"
		ExtraText.Visible = true
		ExtraImage.Visible = false

		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local color = Color3.fromRGB(214, 89, 6)

		TweenService:Create(ExtraText, info, { TextColor3 = color }):Play()

		TweenService:Create(comboDuration, info, { BackgroundColor3 = color }):Play()

		TweenService:Create(ExtraText, info, {
			Size = BASE_ExtraText_SIZE + UDim2.fromScale(0.1, 0.1),
			Rotation = 5,
		}):Play()

		TweenService:Create(damageText, info, {
			TextColor3 = color,
			Size = BASE_SIZE + UDim2.fromScale(0.1, 0.1),
			Rotation = 5,
		}):Play()

		task.delay(0.25, function()
			local shrinkTween =
				TweenService:Create(damageText, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Size = BASE_SIZE - UDim2.fromScale(0.1, 0.1),
					Rotation = 0,
				})
			local shrinkCriticalTween =
				TweenService:Create(ExtraText, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Size = BASE_ExtraText_SIZE - UDim2.fromScale(0.1, 0.1),
					Rotation = 0,
				})
			shrinkTween:Play()
			shrinkCriticalTween:Play()
		end)
	end

	local function StatusEffectTween(statusEffectName)
		local statusEffectData = StatusEffectsData.StatusEffects[statusEffectName]
		local statusFrame = damageFrame.Parent.StatusFrame
		local statusEffectsFrame = statusFrame.StatusEffectsFrame or statusFrame.AilmentsFrame
		ExtraText.Text = statusEffectName
		ExtraText.Visible = true
		ExtraImage.Visible = true

		ExtraImage.Image = statusEffectsFrame[statusEffectData.State].Image
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local color = Color3.fromHex(statusEffectData.Color)

		TweenService:Create(ExtraText, info, { TextColor3 = color }):Play()

		TweenService:Create(comboDuration, info, { BackgroundColor3 = color }):Play()

		TweenService:Create(ExtraText, info, {
			Size = BASE_ExtraText_SIZE + UDim2.fromScale(0.1, 0.1),
			Rotation = 5,
		}):Play()

		TweenService:Create(ExtraImage, info, {
			Size = BASE_ExtraImage_SIZE + UDim2.fromScale(0.05, 0.05),
			Rotation = 5,
		}):Play()

		TweenService:Create(damageText, info, {
			TextColor3 = color,
			Size = BASE_SIZE + UDim2.fromScale(0.1, 0.1),
			Rotation = 5,
		}):Play()

		task.delay(0.25, function()
			local shrinkTween =
				TweenService:Create(damageText, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Size = BASE_SIZE - UDim2.fromScale(0.1, 0.1),
					Rotation = 0,
				})
			local shrinkCriticalTween =
				TweenService:Create(ExtraText, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Size = BASE_ExtraText_SIZE - UDim2.fromScale(0.1, 0.1),
					Rotation = 0,
				})
			local shrinkImageTween =
				TweenService:Create(ExtraImage, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Size = BASE_ExtraImage_SIZE,
					Rotation = 0,
				})
			shrinkTween:Play()
			shrinkImageTween:Play()
			shrinkCriticalTween:Play()
		end)
	end

	NetworkingService:OnClientEvent("ShowDamage", function(damage, critical, blocked, blackFlash, statusEffectName)
		damageFrame.Visible = true

		---ComboDuration---
		comboDuration.Visible = true
		comboDuration.Size = UDim2.fromScale(1, 0.01)
		local info = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local comboDurationTween = TweenService:Create(comboDuration, info, { Size = UDim2.fromScale(0, 0.01) })
		comboDurationTween:Play()
		comboDurationTween.Completed:Connect(function(playbackState)
			if playbackState ~= Enum.PlaybackState.Cancelled then
				damageFrame.Visible = false
				damageText.Text = ""
			end
		end)

		---Text---
		if blackFlash == true then
			BlackFlashTween()
		elseif critical == true then
			CriticalTween()
		elseif blocked == true then
			BlockedTween()
		elseif statusEffectName then
			StatusEffectTween(statusEffectName)
		else
			DefualtTween()
		end

		if tonumber(damageText.Text) then
			damageText.Text = damage + tonumber(damageText.Text)
		else
			damageText.Text = damage
		end
	end)
end

function HUDController:AdminPanel()
	local adminFrame = UIManager:GetUI("HUD", "AdminFrame")
	local textBox = adminFrame:FindFirstChild("TextBox")
	local button = adminFrame:FindFirstChild("Button")

	UIHelper:ClickEffects(button)
	UIHelper:HoverEffects(button)
	UIHelper:RotateGradient(textBox:FindFirstChild("UIStroke"):FindFirstChild("UIGradient"))

	textBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			NetworkingService:FireToServer("AdminCommand", textBox.Text)
		end
	end)

	local AdminIDs = require(game.ReplicatedStorage.Modules.Data.AdminIDs)
	local Player = game:GetService("Players").LocalPlayer
	if not AdminIDs[Player.UserId] then
		adminFrame.Visible = false
		return
	end
	adminFrame.Visible = true
	textBox.Visible = false
	button.Visible = true

	button.MouseButton1Click:Connect(function()
		if textBox.Visible == true then
			textBox.Visible = false
		else
			textBox.Visible = true
		end
	end)
end
return HUDController
