local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
return function()
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local ActionVerifier = require(game.ReplicatedStorage.Modules.Helpers.ActionVerifier)
	local Player = game:GetService("Players").LocalPlayer
	local character = Player.Character or Player.CharacterAdded:Wait()
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	local hrp: Part = character:WaitForChild("HumanoidRootPart")
	local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)
	local camera = workspace.CurrentCamera

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	------------------------------------------------------CoreMovementTweaks-----------------------------------------------------

	---FOV Changes Based On Current Speed---
	local defualtFOV = 70
	Connections:AddConnection(
		character,
		"Character",
		"FOV",
		RunService.RenderStepped:Connect(function(dt)
			TweenService:Create(camera, tweenInfo, { FieldOfView = defualtFOV + humanoid.WalkSpeed / 2 }):Play()
		end)
	)

	------------------------------------------------------MovementAbilties-------------------------------------------------------

	local function GetMoveDirection()
		local MoveDirection = humanoid.MoveDirection
		return Vector3.new(MoveDirection.X, 0, MoveDirection.Z).Unit
	end

	local function GetShiftLockState()
		if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
			return 1
		else
			return 0
		end
	end

	UserInputService.InputBegan:Connect(function(input)
		------Sprinting------
		if input.KeyCode == Enum.KeyCode.LeftShift then
			NetworkingService:FireToServer("Sprint")
		end

		------Dashing & FlashStep------
		if input.KeyCode == Enum.KeyCode.Q then
			---FlashStep---
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				NetworkingService:FireToServer("FlashStep")
			else
				---Dashing---
				local direction = GetMoveDirection()
				if direction and ActionVerifier:CanDash(character) then
					NetworkingService:FireToServer("Dash", direction, GetShiftLockState())
				end
			end
		end
	end)
end
