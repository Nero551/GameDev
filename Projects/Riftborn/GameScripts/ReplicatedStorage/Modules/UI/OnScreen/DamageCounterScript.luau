local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
return function(damageFrame)
	local TweenService = game:GetService("TweenService")
	local repstor = game:GetService("ReplicatedStorage")
	local damageText = damageFrame.DamageNumber
	local comboDuration = damageFrame.ComboDuration
	local remotes = repstor.Remotes
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
		
		local color = Color3.fromRGB(176,176,176)
		
		TweenService:Create(comboDuration, info , {BackgroundColor3 = color}):Play()


		TweenService:Create(damageText, info, {
			TextColor3 = color,
			Size = BASE_SIZE + UDim2.fromScale(0.05,0.05)}):Play()

		task.delay(0.25, function()
			local shrinkTween = TweenService:Create(damageText, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = BASE_SIZE - UDim2.fromScale(0.05,0.05)
			})
			shrinkTween:Play()
		end)
	end

	local function BlockedTween()
		ExtraText.Text = "BLOCKED"
		ExtraImage.Visible = false
		ExtraText.Visible = true
		local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		local color = Color3.fromRGB(41,41,255)
		
		TweenService:Create(ExtraText, info, {TextColor3 = color}):Play()
		
		TweenService:Create(comboDuration, info , {BackgroundColor3 = color}):Play()
		
		TweenService:Create(damageText, info, {
			TextColor3 = color,
			Size = BASE_SIZE + UDim2.fromScale(0.05,0.05)}):Play()


		task.delay(0.25, function()
			local shrinkTween = TweenService:Create(damageText, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = BASE_SIZE - UDim2.fromScale(0.05,0.05)
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
		
		TweenService:Create(ExtraText, info, {TextColor3 = color}):Play()
		
		TweenService:Create(comboDuration, info , {BackgroundColor3 = color}):Play()
		
		TweenService:Create(ExtraText, info, {
			Size = BASE_ExtraText_SIZE + UDim2.fromScale(0.1,0.1),
			Rotation = 5}):Play()

		TweenService:Create(damageText, info, {
			TextColor3 = color,
			Size = BASE_SIZE + UDim2.fromScale(0.1,0.1),
			Rotation = 5}):Play()

		task.delay(0.25, function()
			local shrinkTween = TweenService:Create(damageText, TweenInfo.new(0.5, Enum.EasingStyle.Sine , Enum.EasingDirection.InOut), {
				Size = BASE_SIZE - UDim2.fromScale(0.1,0.1), Rotation = 0
			})
			local shrinkCriticalTween = TweenService:Create(ExtraText, TweenInfo.new(0.5, Enum.EasingStyle.Sine , Enum.EasingDirection.InOut), {
				Size = BASE_ExtraText_SIZE - UDim2.fromScale(0.1,0.1), Rotation = 0
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
		
		local color = Color3.fromRGB(214,89,6)
		
		TweenService:Create(ExtraText, info, {TextColor3 = color}):Play()

		TweenService:Create(comboDuration, info , {BackgroundColor3 = color}):Play()
		
		TweenService:Create(ExtraText, info, {
			Size = BASE_ExtraText_SIZE + UDim2.fromScale(0.1,0.1),
			Rotation = 5}):Play()

		TweenService:Create(damageText, info, {
			TextColor3 = color,
			Size = BASE_SIZE + UDim2.fromScale(0.1,0.1),
			Rotation = 5}):Play()

		task.delay(0.25, function()
			local shrinkTween = TweenService:Create(damageText, TweenInfo.new(0.5, Enum.EasingStyle.Sine , Enum.EasingDirection.InOut), {
				Size = BASE_SIZE - UDim2.fromScale(0.1,0.1), Rotation = 0
			})
			local shrinkCriticalTween = TweenService:Create(ExtraText, TweenInfo.new(0.5, Enum.EasingStyle.Sine , Enum.EasingDirection.InOut), {
				Size = BASE_ExtraText_SIZE - UDim2.fromScale(0.1,0.1), Rotation = 0
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

		TweenService:Create(ExtraText, info, {TextColor3 = color}):Play()

		TweenService:Create(comboDuration, info , {BackgroundColor3 = color}):Play()

		TweenService:Create(ExtraText, info, {
			Size = BASE_ExtraText_SIZE + UDim2.fromScale(0.1,0.1),
			Rotation = 5}):Play()

		TweenService:Create(ExtraImage, info, {
			Size = BASE_ExtraImage_SIZE + UDim2.fromScale(0.05, 0.05),
			Rotation = 5}):Play()	

		TweenService:Create(damageText, info, {
			TextColor3 = color,
			Size = BASE_SIZE + UDim2.fromScale(0.1,0.1),
			Rotation = 5}):Play()

		task.delay(0.25, function()
			local shrinkTween = TweenService:Create(damageText, TweenInfo.new(0.5, Enum.EasingStyle.Sine , Enum.EasingDirection.InOut), {
				Size = BASE_SIZE - UDim2.fromScale(0.1,0.1), Rotation = 0
			})
			local shrinkCriticalTween = TweenService:Create(ExtraText, TweenInfo.new(0.5, Enum.EasingStyle.Sine , Enum.EasingDirection.InOut), {
				Size = BASE_ExtraText_SIZE - UDim2.fromScale(0.1,0.1), Rotation = 0
			})
			local shrinkImageTween = TweenService:Create(ExtraImage, TweenInfo.new(0.5, Enum.EasingStyle.Sine , Enum.EasingDirection.InOut), {
				Size = BASE_ExtraImage_SIZE, Rotation = 0})
			shrinkTween:Play()
			shrinkImageTween:Play()
			shrinkCriticalTween:Play()
		end)
	end
	
	NetworkingService:OnClientEvent("ShowDamage", function(damage, critical, blocked, blackFlash, ailmentName, ailmentData)
		damageFrame.Visible = true

		---ComboDuration---
		comboDuration.Visible = true
		comboDuration.Size = UDim2.fromScale(1 , 0.01)
		local info = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local comboDurationTween = TweenService:Create(comboDuration, info , {Size = UDim2.fromScale(0 , 0.01)})
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
		elseif blocked ==  true then
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
	end)
end