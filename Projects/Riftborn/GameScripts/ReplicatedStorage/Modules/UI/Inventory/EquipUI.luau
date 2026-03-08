local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
return function(itemFrame, OnScreenGui, infoFrame)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local repstor = game:GetService("ReplicatedStorage")
	local tweenService = game:GetService("TweenService")
	local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)

	local remotes = repstor.Remotes

	local box = infoFrame:FindFirstChild("Equip(HoverSoundSizeChange)")

	local equipButton = box:FindFirstChild("EquipButton(ClickSoundSizeChange)")
	local unequipButton = box:FindFirstChild("UnEquipButton(ClickSoundSizeChange)")
	local toolIcons = OnScreenGui.Tools

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	box.MouseEnter:Connect(function()
		tweenService:Create(box, info, { ImageColor3 = Color3.fromRGB(55, 67, 122) }):Play()
	end)

	box.MouseLeave:Connect(function()
		tweenService:Create(box, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)

	local function SwitchInEquip()
		local info = TweenInfo.new(0.0625, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		tweenService:Create(equipButton, info, { TextTransparency = 0 }):Play()
		tweenService:Create(unequipButton, info, { TextTransparency = 1 }):Play()
		task.wait(0.1)
		equipButton.Visible = true
		unequipButton.Visible = false
	end

	local function SwitchOutEquip()
		local info = TweenInfo.new(0.0625, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		tweenService:Create(equipButton, info, { TextTransparency = 1 }):Play()
		tweenService:Create(unequipButton, info, { TextTransparency = 0 }):Play()
		task.wait(0.1)
		equipButton.Visible = false
		unequipButton.Visible = true
	end

	infoFrame:GetAttributeChangedSignal("ItemName"):Connect(function()
		for _, icon in itemFrame:GetChildren() do
			if icon:IsA("Frame") then
				if infoFrame:GetAttribute("ItemName") == icon.Name then
					if icon:GetAttribute("IconEquipState") == true then
						SwitchOutEquip()
					else
						SwitchInEquip()
					end
				end
			end
		end
	end)

	---Equip Item---
	equipButton.MouseButton1Click:Connect(function()
		local itemID = infoFrame:GetAttribute("ItemID")
		remotes.EquipItem:FireServer(itemID)
		SwitchOutEquip()
	end)

	---unEquip Item---
	unequipButton.MouseButton1Click:Connect(function()
		local itemID = infoFrame:GetAttribute("ItemID")
		remotes.UnequipItem:FireServer(itemID)
		SwitchInEquip()
	end)

	---LoadEquippedItems---
	NetworkingService:OnClientEvent("UpdateEquippedItems", function(equippedItems)
		for _, iconFrame: Frame in itemFrame:GetChildren() do
			if iconFrame:IsA("Frame") then
				if iconFrame:GetAttribute("IconEquipState") == true then
					local icon = iconFrame:FindFirstChild(iconFrame.Name)
					iconFrame:SetAttribute("IconEquipState", false)
					icon.EquippedIcon.Visible = false
				end
			end
		end

		for _, slot in toolIcons:GetChildren() do
			if slot:IsA("ImageButton") then
				slot.ToolName.Value = ""
				slot.Icon.Image = ""
				slot.Visible = false
			end
		end

		for itemType, itemID in pairs(equippedItems) do
			local itemData = ItemDataBase:GetItemData(itemID)
			if not itemData then return end

			local iconFrame = itemFrame:FindFirstChild(itemData.Name)
			local icon = nil
			if iconFrame then
				icon = iconFrame:FindFirstChild(itemData.Name)
			end

			iconFrame:SetAttribute("IconEquipState", true)
			icon.EquippedIcon.Visible = true

			local slot = toolIcons:FindFirstChild(itemType .. "Slot")
			if slot then
				slot.ToolName.Value = itemData.Name
				slot.Icon.Image = itemData.Icon
				slot.Visible = true
			end
		end
	end)
end
