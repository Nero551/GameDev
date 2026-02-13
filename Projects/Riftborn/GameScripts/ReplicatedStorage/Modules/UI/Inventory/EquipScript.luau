return function  (itemFrame, OnScreenGui, infoFrame)
	local repstor = game:GetService("ReplicatedStorage")
	local player = game:GetService("Players").LocalPlayer
	local tweenService = game:GetService("TweenService")
	
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid:Humanoid = char:FindFirstChild("Humanoid")
	
	local remotes = repstor.Remotes
	
	local box = infoFrame:FindFirstChild("Equip(HoverSoundSizeChange)")
	
	local equipButton = box:FindFirstChild("EquipButton(ClickSoundSizeChange)")
	local unequipButton = box:FindFirstChild("UnEquipButton(ClickSoundSizeChange)")
	local toolIcons = OnScreenGui.Tools
	local infoNameValue = infoFrame:FindFirstChild("ItemNameValue")

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	box.MouseEnter:Connect(function()
		tweenService:Create(box, info , {ImageColor3 = Color3.fromRGB(55, 67, 122)}):Play()
	end)

	box.MouseLeave:Connect(function()
		tweenService:Create(box, info , {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
	end)

	local function SwitchInEquip()
		local info =  TweenInfo.new(0.0625, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		tweenService:Create(equipButton, info , {TextTransparency = 0}):Play()
		tweenService:Create(unequipButton, info , {TextTransparency = 1}):Play()
		wait(0.1)
		equipButton.Visible = true
		unequipButton.Visible = false
	end

	local function SwitchOutEquip()
		local info =  TweenInfo.new(0.0625, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		tweenService:Create(equipButton, info , {TextTransparency = 1}):Play()
		tweenService:Create(unequipButton, info , {TextTransparency = 0}):Play()
		wait(0.1)
		equipButton.Visible = false
		unequipButton.Visible = true
	end


	infoNameValue.Changed:Connect(function()
		for _,icon in itemFrame:GetChildren() do
			if icon:IsA("Frame") then
				if infoNameValue.Value == icon.Name then
					local equipState:BoolValue = icon:FindFirstChild(icon.Name):FindFirstChild("IconEquipState")
					if equipState.Value == true then
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
		local itemType = infoFrame:FindFirstChild("ItemType").Text
		local itemName = infoFrame:FindFirstChild("ItemName").Text
		local itemImage = infoFrame:FindFirstChild("ItemImage").Image
		local itemID = infoFrame:FindFirstChild("ItemID").Value

		remotes.EquipItem:FireServer(itemID)

		if itemType == "Melee" then
			local slot = toolIcons:FindFirstChild("MeleeSlot")
			slot.ToolName.Value = itemName
			slot.Icon.Image = itemImage
			slot.Visible = true

		elseif itemType == "Sword" then 
			local slot = toolIcons:FindFirstChild("SwordSlot")
			slot.ToolName.Value = itemName
			slot.Icon.Image = itemImage
			slot.Visible = true	
		end

		SwitchOutEquip()
	end)

	---unEquip Item---
	unequipButton.MouseButton1Click:Connect(function()
		local itemType = infoFrame:FindFirstChild("ItemType").Text
		local itemName = infoFrame:FindFirstChild("ItemName").Text
		local itemImage = infoFrame:FindFirstChild("ItemImage").Image
		local itemID = infoFrame:FindFirstChild("ItemID").Value

		remotes.UnequipItem:FireServer(itemID)

		if itemType == "Melee" then
			local slot = toolIcons:FindFirstChild("MeleeSlot")
			slot.ToolName.Value = ""
			slot.Icon.Image = ""
			slot.Visible = false

		elseif itemType == "Sword" then
			local slot = toolIcons:FindFirstChild("SwordSlot")
			slot.ToolName.Value = ""
			slot.Icon.Image = ""
			slot.Visible = false	
		end

		SwitchInEquip()
	end)

	---LoadEquippedItems---
	remotes.UpdateEquippedItems.OnClientEvent:Connect(function(inventory, equippedItems)

		for _,icon in itemFrame:GetChildren() do
			if icon:IsA("Frame") then
				if infoNameValue.Value == icon.Name then
					local equipState:BoolValue = icon:FindFirstChild(icon.Name):FindFirstChild("IconEquipState")
					if equipState.Value == true then
						SwitchOutEquip()
					else
						SwitchInEquip()
					end
				end

			end
		end

		for  itemID, item in pairs(inventory) do
			if equippedItems[item.Type] == itemID then
				if item.Type == "Sword" then
					local slot = toolIcons:FindFirstChild("SwordSlot")
					slot.ToolName.Value = item.Name 
					slot.Icon.Image = item.Icon
					slot.Visible = true

				elseif  item.Type == "Melee" then
					local slot = toolIcons:FindFirstChild("MeleeSlot")
					slot.ToolName.Value = item.Name
					slot.Icon.Image = item.Icon
					slot.Visible = true		
				end

			else
				if item.Type == "Sword" then
					local slot = toolIcons:FindFirstChild("SwordSlot")
					slot.ToolName.Value = ""
					slot.Icon.Image = ""
					slot.Visible = false

				elseif item.Type == "Melee" then
					local slot = toolIcons:FindFirstChild("MeleeSlot")
					slot.ToolName.Value = ""
					slot.Icon.Image = ""
					slot.Visible = false

				end
			end	
		end
	end)
end