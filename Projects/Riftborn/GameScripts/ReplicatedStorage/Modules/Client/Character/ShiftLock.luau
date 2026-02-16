return function()
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")

	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid:Humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")
	local crosshair = player.PlayerGui.ShiftLock.Crosshair
	local StateService = require(game.ReplicatedStorage.Modules.StateService)



	-- SETTINGS
	local SHIFT_OFFSET = Vector3.new(1.75, 0, 0)
	local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local shiftLocked = false
	local offsetTween

	local function resetShiftLock()
		shiftLocked = false
		humanoid.AutoRotate = true
		UIS.MouseIconEnabled = true
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		crosshair.Visible = false
		humanoid.CameraOffset = Vector3.zero
	end

	local function setShiftLock(state)
		if shiftLocked == state then return end -- avoid double toggles
		shiftLocked = state

		if offsetTween then
			offsetTween:Cancel()
		end

		offsetTween = TweenService:Create(
			humanoid,
			TWEEN_INFO,
			{CameraOffset = state and SHIFT_OFFSET or Vector3.zero}
		)
		offsetTween:Play()

		humanoid.AutoRotate = not state

		if not state then
			resetShiftLock()
		end
	end


	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.LeftAlt then
			setShiftLock(not shiftLocked)
		end
	end)


	RunService.RenderStepped:Connect(function(dt)

		
		if StateService.checkState(character, "Dead") and shiftLocked then
			resetShiftLock()
			return
		end

		if not shiftLocked then
			return
		end

		-- Shiftlock active behavior
		crosshair.Visible = true
		UIS.MouseIconEnabled = false
		if UIS.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
			UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		end

		local camLook = camera.CFrame.LookVector
		local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
		if flatLook.Magnitude > 0 then
			local target = CFrame.lookAt(root.Position, root.Position + flatLook)
			root.CFrame = root.CFrame:Lerp(target, dt * 12)
		end
	end)


	UIS.WindowFocusReleased:Connect(function()
		if shiftLocked then
			UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		else
			resetShiftLock()
		end
	end)
end