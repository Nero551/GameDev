local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local QuestData = require(ReplicatedStorage.Modules.Data.QuestData)
local TechniqueData = require(game.ReplicatedStorage.Modules.Data.TechniqueData)
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
	local keybinds = player:FindFirstChild("Settings"):FindFirstChild("Keybinds")

	local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function UpdateToolSelection()
		local activeHand = char:GetAttribute("ActiveHand")

		for _, slot in UIManager:GetUI("HUD", "Tools"):GetChildren() do
			if slot:IsA("Frame") then
				local catagory = equipped:FindFirstChild("Weapons"):FindFirstChild(slot.Name)
				TweenService:Create(slot.UIStroke, info, { Color = Color3.fromRGB(116, 116, 116) }):Play()

				if catagory and catagory:GetAttribute("ItemID") == activeHand then
					TweenService:Create(slot.UIStroke, info, { Color = Color3.fromRGB(255, 255, 255) }):Play()
				end
			end
		end
	end

	local function UpdateTools()
		for _, catagory in equipped:FindFirstChild("Weapons"):GetChildren() do
			local itemID = catagory:GetAttribute("ItemID")
			local itemData = ItemDataBase:GetItemData(itemID)
			local slot = UIManager:GetUI("HUD", catagory.Name)
			if slot then
				slot.Visible = true
				slot.TextWBackground.TextLabel.Text = itemData.Name
			end
		end
		UpdateToolSelection()
	end

	-- for _, slot in UIManager:GetUI("HUD", "Tools"):GetChildren() do
	-- 	if slot:IsA("Frame") then

	-- 		slot.MouseButton1Click:Connect(function()
	-- 			local type = equipped:FindFirstChild("Weapons"):FindFirstChild(slot.Name:split("Slot")[1])
	-- 			if type then
	-- 				local itemID = type:GetAttribute("Equipped")
	-- 				if char:GetAttribute("InHand") == itemID then
	-- 					NetworkingService:FireToServer("RequestRemoveFromHand", itemID)
	-- 				else
	-- 					if char:GetAttribute("InHand") ~= "" then
	-- 						NetworkingService:FireToServer("RequestRemoveFromHand", itemID)
	-- 					end
	-- 					NetworkingService:FireToServer("RequestPutInHand", itemID)
	-- 				end
	-- 			end
	-- 		end)
	-- 	end
	-- end

	UserInputService.InputBegan:Connect(function(inp, proc)
		if proc then
			return
		end

		for _, slot in UIManager:GetUI("HUD", "Tools"):GetChildren() do
			if slot:IsA("Frame") then
				local val = equipped:FindFirstChild("Weapons"):FindFirstChild(slot.Name)
				if val then
					local itemID = val:GetAttribute("ItemID")
					if itemID and inp.KeyCode.Name == keybinds:GetAttribute(slot.Name) then
						NetworkingService:FireToServer("SetActiveHand", itemID)
					end
				end
			end
		end
	end)

	local function UpdateKeys()
		for _, slot in UIManager:GetUI("HUD", "Tools"):GetChildren() do
			if slot:IsA("Frame") then
				if keybinds:GetAttribute(slot.Name) then
					slot.Letter.Text = keybinds:GetAttribute(slot.Name)
				end
			end
		end
	end

	UpdateTools()
	equipped.Weapons.ChildAdded:Connect(UpdateTools)
	equipped.Weapons.ChildRemoved:Connect(UpdateTools)

	UpdateToolSelection()
	char:GetAttributeChangedSignal("ActiveHand"):Connect(UpdateToolSelection)

	UpdateKeys()
	keybinds.AttributeChanged:Connect(UpdateKeys)
end

function HUDController:Techniques()
	local char = player.Character or player.CharacterAdded:Wait()
	local stateFolder = char:WaitForChild("State")
	local techniques = player:FindFirstChild("Techniques")
	local equippedTechsFrame = UIManager:GetUI("HUD", "TechniquesFrame")
	local keybinds = player:FindFirstChild("Settings"):FindFirstChild("Keybinds")

	local TechSlots = {}
	local Keys = {}

	for _, techSlot in equippedTechsFrame:GetChildren() do
		TechSlots[techSlot.Name] = techSlot
	end

	local function UpdateKeys()
		for _, techSlot in equippedTechsFrame:GetChildren() do
			if keybinds:GetAttribute(techSlot.Name) then
				Keys[keybinds:GetAttribute(techSlot.Name)] = techSlot.Name
				techSlot.Letter.Text = keybinds:GetAttribute(techSlot.Name)
			end
		end
	end

	---Use Techniques---
	UserInputService.InputBegan:Connect(function(inp, proc)
		if proc then
			return
		end

		if Keys[inp.KeyCode.Name] then
			NetworkingService:FireToServer(
				"Technique",
				tonumber(Keys[inp.KeyCode.Name]:split("Technique")[2]),
				player:GetMouse().Hit.Position
			)
		end
	end)

	local function UpdateCooldowns()
		for _, techSlot in equippedTechsFrame:GetChildren() do
			if techSlot:IsA("TextButton") then
				if StateChecker:CheckState(char, techSlot.Name .. " Cooldown") then
					local state = stateFolder:FindFirstChild(techSlot.Name .. " Cooldown")
					local techniqueData = TechniqueData:GetTechniqueData(
						techniques.Equipped
							:FindFirstChild(techSlot.Name:split("Technique")[2])
							:GetAttribute("TechniqueID")
					)
					techSlot.TechniqueName.Visible = false
					techSlot.CDTime.Visible = true
					techSlot.CDBox.Visible = true
					if state:GetAttribute("Duration") then
						state:GetAttributeChangedSignal("Duration"):Connect(function()
							techSlot.CDTime.Text = math.round(state:GetAttribute("Duration"))
							TweenService:Create(
								techSlot.CDBox,
								TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = UDim2.fromScale(
										1,
										(state:GetAttribute("Duration") / techniqueData.Cooldown)
									),
								}
							):Play()
						end)
						techSlot.CDTime.Text = math.round(state:GetAttribute("Duration"))
					end
				else
					techSlot.TechniqueName.Visible = true
					techSlot.CDTime.Visible = false
					techSlot.CDBox.Visible = false
				end
			end
		end
	end

	local function UpdateTechniques()
		for _, equippedTech in equippedTechsFrame:GetChildren() do
			if equippedTech:IsA("TextButton") then
				local techSlot = techniques.Equipped:FindFirstChild(equippedTech.Name:split("Technique")[2])
				if techSlot then
					local techniqueID = techSlot:GetAttribute("TechniqueID")
					local techniqueData = TechniqueData:GetTechniqueData(techniqueID)
					if techniqueData then
						equippedTech.TechniqueName.Text = techniqueData.TechniqueName
					end
				else
					equippedTech.TechniqueName.Text = ""
				end
			end
		end
	end

	UpdateTechniques()
	techniques.Equipped.ChildAdded:Connect(UpdateTechniques)
	techniques.Equipped.ChildRemoved:Connect(UpdateTechniques)

	UpdateKeys()
	keybinds.AttributeChanged:Connect(UpdateKeys)

	UpdateCooldowns()
	stateFolder.ChildAdded:Connect(UpdateCooldowns)
	stateFolder.ChildRemoved:Connect(UpdateCooldowns)
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

	local DialogueText = DialogueFrame.DialogueText
	local SpeakerName = DialogueFrame.SpeakerName

	local skipLine = false
	local canClick = true

	DialogueFrame.ClickOverlay.MouseButton1Click:Connect(function()
		if skipLine == true and canClick == true then
			NetworkingService:FireToServer("ContinueDialogue", player)
		end
		skipLine = true
	end)

	local function PlayLine(speaker, line)
		DialogueFrame.Visible = true
		SpeakerName.TextLabel.Text = speaker
		DialogueText.Text = ""

		skipLine = false
		local i = 0
		local length = #line

		while i < length do
			i += 1
			DialogueText.Text = string.sub(line, 1, i)
			ReplicatedStorage.Assets.MenuSounds.DialogueSound:Play()
			if skipLine then
				DialogueText.Text = line
				break
			end
			task.wait(0.03)
		end
		skipLine = true
	end

	NetworkingService:OnClientEvent("ShowDialogue", function(speaker, text, options, ended)
		for _, optionButton in DialogueFrame.OptionsFrame:GetChildren() do
			if optionButton:IsA("TextButton") then
				optionButton:Destroy()
			end
		end

		if ended then
			DialogueFrame.Visible = false
			SpeakerName.TextLabel.Text = ""
			DialogueText.Text = ""
			return
		end

		PlayLine(speaker, text)

		if options then
			for option, optioninfo in pairs(options) do
				local optionButton =
					UIManager:CloneUI("HUD", option, ReplicatedStorage.Assets.UI.DialogueOption, "OptionsFrame")
				optionButton.TextLabel.Text = optioninfo.Text
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
				trackedQuestFrame.TrackedQuestName.TextLabel.Text = trackedQuestData.Name

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

	local function DefaultTween()
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

		---Text---
		damageText.Text = damage + (tonumber(damageText.Text) or 0)

		if blackFlash then
			BlackFlashTween()
		elseif critical then
			CriticalTween()
		elseif blocked then
			BlockedTween()
		elseif statusEffectName then
			StatusEffectTween(statusEffectName)
		else
			DefaultTween()
		end

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
