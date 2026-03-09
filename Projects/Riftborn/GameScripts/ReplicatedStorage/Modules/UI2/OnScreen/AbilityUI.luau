return function(abilityUI)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Player = game:GetService("Players").LocalPlayer
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local char = Player.Character or Player.CharacterAdded:Wait()
	local modules = ReplicatedStorage.Modules
	local StateChecker = require(modules.StateChecker)
	local AbilityData = require(modules.Data.AbilityData)
	local ItemDataBase = require(modules.Data.ItemDataBase)
	local bars = {}

	local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)

	-- cache UI
	for _, ui in abilityUI:GetChildren() do
		if ui:IsA("ImageLabel") then
			local abilityKey = ui.Name:split("AbilityBar")[2]
			bars[abilityKey] = {
				bar = ui,
				cdBar = ui:WaitForChild("CDBar"),
				nameLabel = ui:WaitForChild("AbilityName"),
				cdActive = false,
				cdText = ui:WaitForChild("CDText"),
				cdEndTime = nil,
				abilityLetter = ui:WaitForChild("AbilityLetter"),
				innerStroke = ui:WaitForChild("InnerStroke(RotGrad)")
			}

			ui.Visible = false
			bars[abilityKey].cdBar.Visible = false
			bars[abilityKey].cdBar.Size = UDim2.fromScale(-0.97,0.87)
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
			local abilityData = AbilityData.getAbilityData(tool.Name , abilityKey)
			local weaponData = ItemDataBase:GetItemData(tool.Name, "Weapon")
			if not abilityData then
				data.bar.Visible = false
				continue
			end

			data.bar.Visible = true
			data.nameLabel.Text = abilityData.AbilityName
			local cdStateName = "Ability"..abilityKey.." Cooldown"
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
					{ Size = UDim2.fromScale(0,0.87) }
				)

				tween:Play()
				tween.Completed:Once(function()
					data.cdActive = false
					data.cdBar.Visible = false
					data.cdBar.Size = UDim2.fromScale(-0.97,0.87)
					data.cdText.Text = ""
					data.cdEndTime = nil
				end)
			end

			---Looks BS---
			if weaponData.Type == "Sword" then

				TweenService:Create(data.nameLabel, info, {TextColor3 = Color3.fromHex("#ffe134")}):Play()
				TweenService:Create(data.abilityLetter, info, {TextColor3 = Color3.fromHex("#ffe134")}):Play()
				TweenService:Create(data.innerStroke, info , {ImageColor3 = Color3.fromHex("#ffe134")}):Play()

			elseif weaponData.Type == "Melee" then

				TweenService:Create(data.nameLabel, info, {TextColor3 = Color3.fromHex("#ff2c30")}):Play()
				TweenService:Create(data.abilityLetter, info, {TextColor3 = Color3.fromHex("#ff2c30")}):Play()
				TweenService:Create(data.innerStroke, info , {ImageColor3 = Color3.fromHex("#ff2c30")}):Play()

			elseif weaponData.Type == "Grimiore" then

				TweenService:Create(data.nameLabel, info, {TextColor3 = Color3.fromHex("#1cd9ff")}):Play()
				TweenService:Create(data.abilityLetter, info, {TextColor3 = Color3.fromHex("#1cd9ff")}):Play()
				TweenService:Create(data.innerStroke, info , {ImageColor3 = Color3.fromHex("#1cd9ff")}):Play()

			elseif weaponData.Type == "RiftBorn" then

				TweenService:Create(data.nameLabel, info, {TextColor3 = Color3.fromHex("#b520ff")}):Play()
				TweenService:Create(data.abilityLetter, info, {TextColor3 = Color3.fromHex("#b520ff")}):Play()
				TweenService:Create(data.innerStroke, info , {ImageColor3 = Color3.fromHex("#b520ff")}):Play()
			end
		end
	end)

end