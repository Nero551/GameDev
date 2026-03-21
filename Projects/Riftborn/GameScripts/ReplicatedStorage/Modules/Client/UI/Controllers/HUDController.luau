local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local AbilityData = require(game.ReplicatedStorage.Modules.Data.AbilityData)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local UIHelper = require(game.ReplicatedStorage.Modules.Client.UI.UIHelper)
local UIManager = require(game.ReplicatedStorage.Modules.Client.UI.UIManager)

local HUDController = {}

local player = Players.LocalPlayer

function HUDController:HealthBar()
	local char = player.Character or player.CharacterAdded:Wait()
	local healthBG: ImageLabel = UIManager:GetUI("HUD", "HealthBG")
	local healthFill: ImageLabel = UIManager:GetUI("HUD", "HealthFill")
	local healthText: TextLabel = UIManager:GetUI("HUD", "HealthText")
	local healthNumber: TextLabel = UIManager:GetUI("HUD", "HealthNumber")
	local Stroke = healthBG:FindFirstChild("Stroke")

	UIHelper:RotateGradient(healthFill:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(Stroke:FindFirstChild("UIGradient"))

	local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local info2 = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function UpdateHealth()
		local currentHealth = char:GetAttribute("Health_CurrentHealth")
		local maxHealth = char:GetAttribute("Health_MaxHealth")
		TweenService:Create(healthFill, info, { Size = UDim2.fromScale(currentHealth / maxHealth, 1) }):Play()
		healthNumber.Text = math.round(currentHealth) .. "/" .. math.round(maxHealth)

		if maxHealth / 3 > currentHealth then
			TweenService:Create(healthNumber, info2, { TextColor3 = Color3.fromRGB(255, 140, 150) }):Play()
			TweenService:Create(healthText, info2, { TextColor3 = Color3.fromRGB(255, 140, 150) }):Play()
		else
			TweenService:Create(healthNumber, info2, { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
			TweenService:Create(healthText, info2, { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		end
	end

	char:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(UpdateHealth)
	char:GetAttributeChangedSignal("Health_MaxHealth"):Connect(UpdateHealth)
end

function HUDController:ManaBar()
	local char = player.Character or player.CharacterAdded:Wait()
	local ManaBG = UIManager:GetUI("HUD", "ManaBG")
	local ManaFill = UIManager:GetUI("HUD", "ManaFill")
	local ManaNumber = UIManager:GetUI("HUD", "ManaNumber")
	local Stroke = ManaBG:FindFirstChild("Stroke")

	UIHelper:RotateGradient(ManaFill:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(Stroke:FindFirstChild("UIGradient"))

	local function UpdateMana()
		local CurrentMana = char:GetAttribute("Mana_CurrentMana")
		local MaxMana = char:GetAttribute("Mana_MaxMana")
		local info = TweenInfo.new(0.04, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
		TweenService:Create(ManaFill, info, { Size = UDim2.fromScale(CurrentMana / MaxMana, 1) }):Play()
		ManaNumber.Text = math.round(CurrentMana) .. "/" .. math.round(MaxMana)
	end

	UpdateMana()
	char:GetAttributeChangedSignal("Mana_CurrentMana"):Connect(UpdateMana)
	char:GetAttributeChangedSignal("Mana_MaxMana"):Connect(UpdateMana)
end

function HUDController:EXPBar()
	local level = player:WaitForChild("PlayerLevel")
	local currentEXP = level:FindFirstChild("CurrentEXP")
	local requiredEXP = level:FindFirstChild("RequiredEXP")

	local expBG = UIManager:GetUI("HUD", "EXPBG")
	local expFill = UIManager:GetUI("HUD", "EXPFill")
	local expNumber = UIManager:GetUI("HUD", "EXPNumber")
	local stroke = expBG:FindFirstChild("Stroke")

	UIHelper:RotateGradient(expFill:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(stroke:FindFirstChild("UIGradient"))

	local function UpdateEXP()
		local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local ratio = currentEXP:GetAttribute("Amount") / requiredEXP:GetAttribute("Amount")
		ratio = math.clamp(ratio, 0, 1)

		TweenService:Create(expFill, info, { Size = UDim2.fromScale(ratio, 1) }):Play()
		expNumber.Text = math.round(currentEXP:GetAttribute("Amount"))
			.. " / "
			.. math.round(requiredEXP:GetAttribute("Amount"))
	end

	UpdateEXP()
	currentEXP:GetAttributeChangedSignal("Amount"):Connect(UpdateEXP)
	requiredEXP:GetAttributeChangedSignal("Amount"):Connect(UpdateEXP)
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

				TweenService:Create(slot, info, { Size = UDim2.fromScale(0.175, 0.953) }):Play()
				TweenService:Create(slot.Border, info, { ImageColor3 = Color3.fromRGB(116, 116, 116) }):Play()

				if type and type:GetAttribute("Equipped") == inHand then
					TweenService:Create(slot, info, { Size = UDim2.fromScale(0.181, 1.16) }):Play()
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
			local abilityData = AbilityData:GetAbilityData(tool.Name, abilityKey)
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
	local statusFolder = char:WaitForChild("Status")
	local inCombatText = UIManager:GetUI("HUD", "InCombatText")

	local function UpdateCombatText()
		if StateChecker:CheckState(char, "In Combat") then
			inCombatText.Visible = true
		else
			inCombatText.Visible = false
		end
	end
	statusFolder.ChildAdded:Connect(UpdateCombatText)

	statusFolder.ChildRemoved:Connect(UpdateCombatText)
end

function HUDController:Ailments()
	local char = player.Character or player.CharacterAdded:Wait()
	local statusFolder = char:WaitForChild("Status")
	local ailmentsFrame = UIManager:GetUI("HUD", "AilmentsFrame")
	local function Ailments()
		for _, ailmentIcon in ailmentsFrame:GetChildren() do
			if not ailmentIcon:IsA("ImageLabel") then
				continue
			end
			if StateChecker:CheckState(char, ailmentIcon.Name) then
				ailmentIcon.Visible = true
				local state = statusFolder:FindFirstChild(ailmentIcon.Name)
				if state:GetAttribute("Duration") then
					state:GetAttributeChangedSignal("Duration"):Connect(function()
						ailmentIcon.Duration.Text = math.floor(state:GetAttribute("Duration"))
					end)
					ailmentIcon.Duration.Text = math.floor(state:GetAttribute("Duration"))
				end
			else
				ailmentIcon.Visible = false
			end
		end
	end
	Ailments()
	statusFolder.ChildAdded:Connect(Ailments)
	statusFolder.ChildRemoved:Connect(Ailments)
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
	local CurrentLevel: Instance = player:WaitForChild("PlayerLevel").CurrentLevel

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

	NetworkingService:OnClientEvent("ShowDialogue", function(speaker, dialogueData, ended)
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

		PlayLine(speaker, dialogueData.Text)

		if dialogueData.Options then
			for option, optioninfo in pairs(dialogueData.Options) do
				local optionButton = ReplicatedStorage.Assets.GUI.DialogueOption:Clone()
				optionButton.Name = option
				optionButton.Text.Text = optioninfo.Text
				optionButton.Parent = DialogueFrame.OptionFrame
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
	local trackQuestbutton = UIManager:GetUI("HUD", "TrackQuestButton")

	local innerStroke = trackQuestbutton.Parent:FindFirstChild("InnerStroke")
	local outerStroke = trackQuestbutton.Parent:FindFirstChild("OuterStroke")
	UIHelper:RotateGradient(innerStroke:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(outerStroke:FindFirstChild("UIGradient"))

	trackQuestbutton.MouseButton1Click:Connect(function()
		local questName = trackQuestbutton.Parent.TrackedQuestName.Text
		NetworkingService:FireToServer("TrackQuest", questName)
	end)

	---Looks BS---
	local function SizeIncrease(scale: UIScale)
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, { Scale = 1.025 }):Play()
	end

	local function SizeDecrease(scale: UIScale)
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, { Scale = 1 }):Play()
	end

	local function SizeClickDecrease(scale: UIScale)
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(scale, info, { Scale = 0.975 }):Play()
	end

	local scale = trackQuestbutton.UIScale

	trackQuestbutton.MouseEnter:Connect(function()
		SizeIncrease(scale)
	end)

	trackQuestbutton.MouseLeave:Connect(function()
		SizeDecrease(scale)
	end)

	trackQuestbutton.MouseButton1Down:Connect(function()
		SizeClickDecrease(scale)
	end)

	trackQuestbutton.MouseButton1Up:Connect(function()
		SizeIncrease(scale)
	end)
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
	local TweenService = game:GetService("TweenService")
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

	local function AilmentTween(ailmentName, ailmentData)
		ExtraText.Text = ailmentName
		ExtraText.Visible = true
		ExtraImage.Visible = true

		ExtraImage.Image = damageFrame.Parent.StatusFrame.AilmentsFrame[ailmentData.State].Image
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local color = Color3.fromHex(ailmentData.Color)

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

	NetworkingService:OnClientEvent(
		"ShowDamage",
		function(damage, critical, blocked, blackFlash, ailmentName, ailmentData)
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
			elseif ailmentName and ailmentData then
				AilmentTween(ailmentName, ailmentData)
			else
				DefualtTween()
			end

			if tonumber(damageText.Text) then
				damageText.Text = damage + tonumber(damageText.Text)
			else
				damageText.Text = damage
			end
		end
	)
end

function HUDController:MainMenuButton()
	local button = UIManager:GetUI("HUD", "MainMenuText")
	UIHelper:ClickEffects(button)
	UIHelper:HoverEffects(button)

	local stroke = button.Parent:FindFirstChild("RGBStroke")
	UIHelper:RotateGradient(stroke:FindFirstChild("UIGradient"))

	local MainMenu = UIManager:GetUI("MainMenu", "MainMenu")
	local texture = UIManager:GetUI("MainMenu", "Texture")
	local Lighting = game:GetService("Lighting")
	local blur = Lighting.Blur

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	button.Parent.MouseEnter:Connect(function()
		TweenService:Create(button.Parent, info, { ImageColor3 = Color3.fromRGB(87, 107, 194) }):Play()
	end)

	button.Parent.MouseLeave:Connect(function()
		TweenService:Create(button.Parent, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)

	local function BackgroundBlurTweenIn()
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(blur, info, { Size = 24 }):Play()
		TweenService:Create(texture, info, { ImageTransparency = 0.8 }):Play()
	end

	local function BackgroundBlurTweenOut()
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(blur, info, { Size = 0 }):Play()
		TweenService:Create(texture, info, { ImageTransparency = 1 }):Play()
	end

	local function OpenMenu()
		MainMenu.Visible = true
		UIManager:SetActiveScreen("MainMenu")
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		TweenService:Create(MainMenu, info, { Size = UDim2.fromScale(0.4, 0.9) }):Play()
	end

	local function CloseMenu()
		UIManager:SetActiveScreen("HUD")
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local tween = TweenService:Create(MainMenu, info, { Size = UDim2.fromScale(0, 0) })
		tween:Play()
		tween.Completed:Connect(function()
			MainMenu.Visible = false
		end)
	end

	button.MouseButton1Click:Connect(function()
		if UIManager.ActiveScreen ~= "MainMenu" then
			OpenMenu()
			BackgroundBlurTweenIn()
		else
			CloseMenu()
			BackgroundBlurTweenOut()
		end
	end)
end

return HUDController
