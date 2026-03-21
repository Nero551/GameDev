local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Player = game:GetService("Players").LocalPlayer
	local remotes = ReplicatedStorage.Remotes
	local assets = ReplicatedStorage.Assets
	local popupTemplate = assets.GUI.PopUp
	local popupsFrame = Player:WaitForChild("PlayerGui"):WaitForChild("PopUpGui"):WaitForChild("PopUpsFrame")
	
	local RarityData = require(game.ReplicatedStorage.Modules.Data.RarityData)


	for _,oldPopup in popupsFrame:GetChildren() do
		if oldPopup:IsA("Frame") and oldPopup.Name == "PopUp" then
			oldPopup:Destroy()
		end
	end

	NetworkingService:OnClientEvent("PopUp", function(popupInfo:any)
		if not popupInfo then return end

		if popupInfo.TitleData  then
			local titleData = popupInfo.TitleData

			local AcquiredTitlePopup = popupTemplate:Clone()
			AcquiredTitlePopup.Parent = popupsFrame

			local colors = titleData.Color

			if colors then
				local randomIndex = math.random(1, #colors)
				local colorStr = colors[randomIndex].Color 

				local r, g, b = colorStr:match("(%d+),%s*(%d+),%s*(%d+)")
				r, g, b = tonumber(r), tonumber(g), tonumber(b)
				local hexColor = string.format("#%02X%02X%02X", r, g, b)

				AcquiredTitlePopup.PopUpText.RichText = true
				AcquiredTitlePopup.PopUpText.Text = 'Acquired Title <font color="'..hexColor..'">'..titleData.Name..'</font>'

			else
				AcquiredTitlePopup.PopUpText.Text = "Acquired Title "..titleData.Name
			end


		end

		---No Mana For Ability---
		if popupInfo.AbilityName and popupInfo.RequiredMana then
			local NoManaPopup = popupTemplate:Clone()
			NoManaPopup.PopUpText.Text = "Not Enough Mana For ["..popupInfo.AbilityName.."] ("..popupInfo.RequiredMana..")"
			NoManaPopup.Parent = popupsFrame
		end


		if not popupInfo.Level then
			---Play Drop Sound---
		end

		---EXP---
		if popupInfo.EXP and popupInfo.EXP ~= 0 then
			local obtainedExpPopup = popupTemplate:Clone()
			obtainedExpPopup.PopUpText.Text = "Obtained <font color=\"#fff131\">" .. popupInfo.EXP .. " EXP </font>"
			obtainedExpPopup.Parent = popupsFrame

		end


		---Level Up---
		if popupInfo.Level then
			local levelPopup =  popupTemplate:Clone()
			levelPopup.PopUpText.Text = "Leveled Up ("..popupInfo.Level.CurrentLevel..")"
			levelPopup.PopUpText.TextColor3 = Color3.fromHex("#fff131")
			levelPopup.Parent =  popupsFrame
			assets.Shared.Sounds.LevelUp:Play()

			---Item Drop---
		elseif popupInfo.ItemName and popupInfo.ItemRarity and popupInfo.ItemAmount then
			local obtainedItemPopup =  assets.GUI.PopUp:Clone()
			obtainedItemPopup.PopUpText.RichText = true
			
			local itemRarityColor = RarityData[popupInfo.ItemRarity].Color
			
			if popupInfo.ItemAmount ~= 1 then
				obtainedItemPopup.PopUpText.Text = 'Obtained '..popupInfo.ItemAmount..' <font color="'..itemRarityColor..'">'..popupInfo.ItemName..'</font>'
			else	
				obtainedItemPopup.PopUpText.Text = 'Obtained <font color="'..itemRarityColor..'">'..popupInfo.ItemName..'</font>'
			end
			obtainedItemPopup.Parent = popupsFrame

			---Currency Drop---
		elseif popupInfo.Currency and popupInfo.CurrencyAmount then
			local obtainedCurrencyPopup = popupTemplate:Clone()
			obtainedCurrencyPopup.PopUpText.RichText = true
			obtainedCurrencyPopup.PopUpText.Text = "Obtained "..popupInfo.CurrencyAmount.." "..popupInfo.Currency
			if popupInfo.Currency == "Yen" then
				obtainedCurrencyPopup.PopUpText.Text = 'Obtained <font color="#ffcf21">'..popupInfo.CurrencyAmount.." "..popupInfo.Currency.."</font>"
			elseif popupInfo.Currency == "Fracta" then
				obtainedCurrencyPopup.PopUpText.Text = 'Obtained <font color="#c022ff">'..popupInfo.CurrencyAmount.." "..popupInfo.Currency.."</font>"
			end
			obtainedCurrencyPopup.Parent = popupsFrame

			---Quest---
		elseif popupInfo.QuestName then
			---Quest Completed---
			if popupInfo.QuestCompleted == true then
				local completedQuestPopup = popupTemplate:Clone()
				completedQuestPopup.PopUpText.RichText = true
				completedQuestPopup.PopUpText.Text = 'Completed Quest  <font color="#4bff8d">"'..popupInfo.QuestName ..'"</font>'
				completedQuestPopup.Parent = popupsFrame
				---Quest Abandoned---
			elseif popupInfo.QuestAbandonded == true then
				local AbandonedQuestPopup = popupTemplate:Clone()
				AbandonedQuestPopup.PopUpText.RichText = true
				AbandonedQuestPopup.PopUpText.Text = 'Abandoned Quest <font color = "#ff030b">"'..popupInfo.QuestName ..'"</font>'
				AbandonedQuestPopup.Parent = popupsFrame
			else
				---Quest Accepted---
				local AcceptedQuestPopup = popupTemplate:Clone()
				AcceptedQuestPopup.PopUpText.RichText = true
				AcceptedQuestPopup.PopUpText.Text = 'Accepted Quest  <font color="#4bff8d">"'..popupInfo.QuestName ..'"</font>'
				AcceptedQuestPopup.Parent = popupsFrame

			end
		end
	end)
end
