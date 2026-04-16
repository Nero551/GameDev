local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local RarityData = require(game.ReplicatedStorage.Modules.Data.RarityData)

local PopupController = {}
local player = Players.LocalPlayer

function PopupController:Creator()
	local popupTemplate = player.PlayerGui.UITemplates.PopUp
	local popupsFrame = UIManager:GetUI("Popups", "Popups")

	for _, oldPopup in popupsFrame:GetChildren() do
		if oldPopup:IsA("Frame") and oldPopup.Name == "PopUp" then
			oldPopup:Destroy()
		end
	end

	NetworkingService:OnClientEvent("PopUp", function(popupInfo: any)
		if not popupInfo then
			return
		end
		local popup = popupTemplate:Clone()
		popup.Parent = popupsFrame

		if popupInfo.Mastery then
			if popupInfo.ID then
				popup.PopUpText.RichText = true
				popup.PopUpText.Text = 'Masteried up <font color="#fff131">'
					.. popupInfo.Mastery
					.. " EXP </font> for"
					.. ItemDataBase:GetItemData(popupInfo.ID).Name
			elseif popupInfo.RequiredMastery then
				popup.PopUpText.Text = "You Require "
					.. (tonumber(popupInfo.RequiredMastery) :: number - tonumber(popupInfo.Mastery) :: number)
					.. " To Use This Technique"
			end
		end

		if popupInfo.MasteryEXP and popupInfo.ID then
			popup.PopUpText.RichText = true
			popup.PopUpText.Text = 'Obtained <font color="#fff131">'
				.. popupInfo.MasteryEXP
				.. " EXP </font> For "
				.. ItemDataBase:GetItemData(popupInfo.ID).Name
		end

		if popupInfo.TitleData then
			local titleData = popupInfo.TitleData

			local colors = titleData.Color

			if colors then
				local keypoints = colors.Keypoints
				local randomIndex = math.random(1, #keypoints)
				local color = keypoints[randomIndex].Value

				local hexColor = string.format(
					"#%02X%02X%02X",
					math.floor(color.R * 255),
					math.floor(color.G * 255),
					math.floor(color.B * 255)
				)

				popup.PopUpText.RichText = true
				popup.PopUpText.Text = 'Acquired Title <font color="' .. hexColor .. '">' .. titleData.Name .. "</font>"
			else
				popup.PopUpText.Text = "Acquired Title " .. titleData.Name
			end
		end

		---No Mana/Stamina For Technique---
		if popupInfo.TechniqueName then
			if popupInfo.RequiredMana then
				popup.PopUpText.Text = "Not Enough Mana For ["
					.. popupInfo.TechniqueName
					.. "] ("
					.. popupInfo.RequiredMana
					.. ")"
			elseif popupInfo.RequiredStamina then
				popup.PopUpText.Text = "Not Enough Stamina For ["
					.. popupInfo.TechniqueName
					.. "] ("
					.. popupInfo.RequiredStamina
					.. ")"
			end
		end

		if popupInfo.Level then
			---Play Drop Sound---
		end

		---EXP---
		if popupInfo.EXP then
			popup.PopUpText.RichText = true
			popup.PopUpText.Text = 'Obtained <font color="#fff131">' .. popupInfo.EXP .. " EXP </font>"
		end

		---Level Up---
		if popupInfo.Level then
			popup.PopUpText.Text = "Leveled Up (" .. popupInfo.Level .. ")"
			popup.PopUpText.TextColor3 = Color3.fromHex("#fff131")
			ReplicatedStorage.Assets.MenuSounds.LevelUp:Play()

			---Item Drop---
		elseif popupInfo.ItemName and popupInfo.ItemRarity and popupInfo.ItemAmount then
			popup.PopUpText.RichText = true

			local itemRarityColor = RarityData[popupInfo.ItemRarity].Color

			if popupInfo.ItemAmount ~= 1 then
				popup.PopUpText.Text = "Obtained "
					.. popupInfo.ItemAmount
					.. ' <font color="'
					.. itemRarityColor
					.. '">'
					.. popupInfo.ItemName
					.. "</font>"
			else
				popup.PopUpText.Text = 'Obtained <font color="'
					.. itemRarityColor
					.. '">'
					.. popupInfo.ItemName
					.. "</font>"
			end

			---Currency Drop---
		elseif popupInfo.Currency and popupInfo.CurrencyAmount then
			popup.PopUpText.RichText = true
			popup.PopUpText.Text = "Obtained " .. popupInfo.CurrencyAmount .. " " .. popupInfo.Currency
			if popupInfo.Currency == "Yen" then
				popup.PopUpText.Text = 'Obtained <font color="#ffcf21">'
					.. popupInfo.CurrencyAmount
					.. " "
					.. popupInfo.Currency
					.. "</font>"
			elseif popupInfo.Currency == "Fracta" then
				popup.PopUpText.Text = 'Obtained <font color="#c022ff">'
					.. popupInfo.CurrencyAmount
					.. " "
					.. popupInfo.Currency
					.. "</font>"
			end

			---Quest---
		elseif popupInfo.QuestName then
			---Quest Completed---
			if popupInfo.QuestCompleted == true then
				popup.PopUpText.RichText = true
				popup.PopUpText.Text = 'Completed Quest  <font color="#4bff8d">"' .. popupInfo.QuestName .. '"</font>'
				---Quest Abandoned---
			elseif popupInfo.QuestAbandonded == true then
				popup.PopUpText.RichText = true
				popup.PopUpText.Text = 'Abandoned Quest <font color = "#ff030b">"' .. popupInfo.QuestName .. '"</font>'
			else
				---Quest Accepted---
				popup.PopUpText.RichText = true
				popup.PopUpText.Text = 'Accepted Quest  <font color="#4bff8d">"' .. popupInfo.QuestName .. '"</font>'
			end
		end
	end)
end

function PopupController:Destroyer()
	local popupsFrame = UIManager:GetUI("Popups", "Popups")
	local info = TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	for _, popup in popupsFrame:GetChildren() do
		if popup:IsA("Frame") then
			popup:Destroy()
		end
	end

	popupsFrame.ChildAdded:Connect(function()
		for _, popup in popupsFrame:GetChildren() do
			if popup:IsA("Frame") then
				task.wait(1)
				local tween = TweenService:Create(popup, info, { Size = UDim2.fromScale(0.3, 0.046) })
				tween:Play()
				tween.Completed:Connect(function()
					popup:Destroy()
				end)
				task.wait(1)
			end
		end
	end)
end

return PopupController
