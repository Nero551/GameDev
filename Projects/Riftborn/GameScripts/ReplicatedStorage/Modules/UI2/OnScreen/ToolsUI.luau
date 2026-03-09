return function(toolSlots)
	local Player = game:GetService("Players").LocalPlayer
	local char = Player.Character or Player.CharacterAdded:Wait()
	local humanoid:Humanoid = char:WaitForChild("Humanoid")
	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")

	---Equips Tool In Backpack---

	local keyToSlot = {
		[Enum.KeyCode.One] = "MeleeSlot",
		[Enum.KeyCode.Two] = "SwordSlot",
		[Enum.KeyCode.Three] = "GrimioreSlot",
		[Enum.KeyCode.Four] = "RiftBornSlot",
	}


	local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local lastSelected
	local selectedSlot
	local function updateSlotTweens()
		for _, slot in toolSlots:GetChildren() do
			if slot:IsA("ImageButton") then
				if slot == selectedSlot then
					TweenService:Create(slot, info, {Size = UDim2.fromScale(0.181,1.16)}):Play()
					TweenService:Create(slot.Border, info, {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				else
					TweenService:Create(slot, info, {Size = UDim2.fromScale(0.175,0.953)}):Play()
					TweenService:Create(slot.Border, info, {ImageColor3 = Color3.fromRGB(116, 116, 116)}):Play()
				end
			end
		end
		lastSelected = selectedSlot
	end


	local function equipSlot(slotName)
		local toolSlot = toolSlots:FindFirstChild(slotName)
		if not toolSlot then return end

		local toolName = toolSlot.ToolName.Value
		local tool = char:FindFirstChild(toolName)
		if tool and tool:IsA("Tool") then
			tool.Parent = Player.Backpack
			selectedSlot = nil
		else
			local tool = Player.Backpack:FindFirstChild(toolName)
			if tool then
				humanoid:EquipTool(tool)
				selectedSlot = toolSlot
			end
		end

		updateSlotTweens()
	end

	UserInputService.InputBegan:Connect(function(inp, proc)
		if proc then return end

		local slotName = keyToSlot[inp.KeyCode]
		if slotName then
			equipSlot(slotName)
		end
	end)


	for _,slot in toolSlots:GetChildren() do
		if slot:IsA("ImageButton") then
			slot.MouseButton1Click:Connect(function()
				equipSlot(slot.Name)
			end)
		end
	end


end