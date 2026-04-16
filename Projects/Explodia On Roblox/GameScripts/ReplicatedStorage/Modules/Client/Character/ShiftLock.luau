return function()
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
	local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)

	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")
	local crosshair = player:WaitForChild("PlayerGui").HUD.Crosshair

	-- SETTINGS
	local SHIFT_OFFSET = Vector3.new(1.75, 0, 0)
	local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local shiftLocked = false
	local offsetTween

	local function resetShiftLock()
		shiftLocked = false
		humanoid.AutoRotate = true
		UserInputService.MouseIconEnabled = true
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		crosshair.Visible = false
		humanoid.CameraOffset = Vector3.zero
	end

	local function setShiftLock(state)
		if shiftLocked == state then
			return
		end -- avoid double toggles
		shiftLocked = state

		if offsetTween then
			offsetTween:Cancel()
		end

		offsetTween =
			TweenService:Create(humanoid, TWEEN_INFO, { CameraOffset = state and SHIFT_OFFSET or Vector3.zero })
		offsetTween:Play()

		humanoid.AutoRotate = not state

		if not state then
			resetShiftLock()
		end
	end

	setShiftLock(false)

	RunService.RenderStepped:Connect(function(dt)
		if
			StateChecker:CheckState(character, "Dead")
			or UIManager.ActiveScreen ~= "HUD"
			or StateChecker:CheckState(character, "MouseAiming")
		then
			setShiftLock(false)
			return
		end

		-- Shiftlock active behavior
		if character:FindFirstChildWhichIsA("Tool") then
			setShiftLock(true)

			crosshair.Visible = true
			UserInputService.MouseIconEnabled = false
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

			local camLook = camera.CFrame.LookVector
			local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
			if flatLook.Magnitude > 0 then
				local target = CFrame.lookAt(root.Position, root.Position + flatLook)
				root.CFrame = root.CFrame:Lerp(target, dt * 12)
			end

			---Disable---
		else
			setShiftLock(false)
		end
	end)

	UserInputService.WindowFocusReleased:Connect(function()
		if shiftLocked then
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		else
			resetShiftLock()
		end
	end)
end
