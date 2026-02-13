return function(damageFrame)
	local TweenService = game:GetService("TweenService")
	local repstor = game:GetService("ReplicatedStorage")
	local damageText = damageFrame.DamageNumber
	local comboDuration = damageFrame.ComboDuration
	local remotes = repstor.Remotes
	local criticalText = damageFrame.CriticalHit

	damageFrame.Visible = false
	damageText.Text = ""
	comboDuration.Visible = false
	criticalText.Visible = false

	local BASE_SIZE = damageText.Size
	local BASE_CRIT_SIZE = criticalText.Size

	local function DefualtTween()
		criticalText.Visible = false
		local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(comboDuration, info , {BackgroundColor3 = Color3.fromRGB(176, 176, 176)}):Play()


		TweenService:Create(damageText, info, {
			TextColor3 = Color3.fromRGB(176, 176, 176),
			Size = BASE_SIZE + UDim2.fromScale(0.05,0.05)}):Play()

		task.delay(0.25, function()
			local shrinkTween = TweenService:Create(damageText, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = BASE_SIZE - UDim2.fromScale(0.05,0.05)
			})
			shrinkTween:Play()
		end)
	end

	local function BlockedTween()
		criticalText.Visible = false
		local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(comboDuration, info , {BackgroundColor3 = Color3.fromRGB(41, 41, 255)}):Play()


		TweenService:Create(damageText, info, {
			TextColor3 = Color3.fromRGB(41, 41, 255),
			Size = BASE_SIZE + UDim2.fromScale(0.05,0.05)}):Play()


		task.delay(0.25, function()
			local shrinkTween = TweenService:Create(damageText, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = BASE_SIZE - UDim2.fromScale(0.05,0.05)
			})
			shrinkTween:Play()
		end)

	end

	local function CriticalTween()
		criticalText.Visible = true
		local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(comboDuration, info , {BackgroundColor3 = Color3.fromRGB(255, 24, 28)}):Play()


		TweenService:Create(criticalText, info, {
			Size = BASE_CRIT_SIZE + UDim2.fromScale(0.1,0.1),
			Rotation = 5}):Play()

		TweenService:Create(damageText, info, {
			TextColor3 = Color3.fromRGB(255, 24, 28),
			Size = BASE_SIZE + UDim2.fromScale(0.1,0.1),
			Rotation = 5}):Play()

		task.delay(0.25, function()
			local shrinkTween = TweenService:Create(damageText, TweenInfo.new(0.5, Enum.EasingStyle.Sine , Enum.EasingDirection.InOut), {
				Size = BASE_SIZE - UDim2.fromScale(0.1,0.1), Rotation = 0
			})
			local shrinkCriticalTween = TweenService:Create(criticalText, TweenInfo.new(0.5, Enum.EasingStyle.Sine , Enum.EasingDirection.InOut), {
				Size = BASE_CRIT_SIZE - UDim2.fromScale(0.1,0.1), Rotation = 0
			})
			shrinkTween:Play()
			shrinkCriticalTween:Play()
		end)
	end


	remotes.ShowDamage.OnClientEvent:Connect(function(damage, critical, blocked)
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
		if critical == true then
			CriticalTween()
		elseif blocked ==  true then
			BlockedTween()
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