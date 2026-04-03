local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local TitleData = require(ReplicatedStorage.Modules.Data.TitleData)
local TitleMenuController = {}

function TitleMenuController:Titles()
	local player = Players.LocalPlayer
	local titles = player:WaitForChild("Titles")
	local scrollingFrame = UIManager:GetUI("StatsMenu", "TitleScrollingFrame")

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

return TitleMenuController
