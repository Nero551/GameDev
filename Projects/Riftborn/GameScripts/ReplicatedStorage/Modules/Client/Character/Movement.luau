local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")
	local runService = game:GetService("RunService")
	local tweenService = game:GetService("TweenService")

	local player = game:GetService("Players").LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid:Humanoid = character:WaitForChild("Humanoid")

	local modules =  replicatedStorage.Modules
	local remotes = replicatedStorage.Remotes

	local Connections = require(ReplicatedStorage.Modules.Connections)
	local StateChecker = require(ReplicatedStorage.Modules.StateChecker)
	local MovementConfig = require(modules.Configs.MovementConfig)

	local DashConfig = MovementConfig.DashConfig
	local camera = workspace.CurrentCamera

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	------------------------------------------------------CoreMovementTweaks-----------------------------------------------------

	---FOV Changes Based On Current Speed---
	local defualtFOV = 70
	Connections:AddConnection(character, "Character", "FOV", runService.RenderStepped:Connect(function(dt)
		tweenService:Create(camera, tweenInfo, {FieldOfView = defualtFOV + humanoid.WalkSpeed/2}):Play()
	end))


	------------------------------------------------------MovementAbilties-------------------------------------------------------

	local function getDashDirection()
		local dashDirection = humanoid.MoveDirection
		return dashDirection.Unit
	end

	UserInputService.InputBegan:Connect(function(input)

		------Sprinting------
		if input.KeyCode == Enum.KeyCode.LeftShift then
			NetworkingService:FireToServer("Sprint")  	
		end

		------Dashing & FlashStep------
		if input.KeyCode == Enum.KeyCode.Q  then
			---FlashStep---
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)  then
				NetworkingService:FireToServer("FlashStep")
			else
				---Dashing---
				local direction = getDashDirection()
				if direction then
					local IsShiftLockOff = UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter
					NetworkingService:FireToServer("Dash", direction, IsShiftLockOff)
				end	
			end
		end
	end)


	---Dash Movement---
	local dashConnection
	remotes.Dash.OnClientEvent:Connect(function(direction, IsShiftLockOff)
		---Dash Movement---	
		local maxDashDistance = DashConfig.MaxDashDistance
		local root:Part = character:FindFirstChild("HumanoidRootPart")

		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		rayParams.FilterDescendantsInstances = {character}

		if dashConnection then
			dashConnection:Disconnect()
			dashConnection = nil
		end
		dashConnection = runService.Heartbeat:Connect(function(dt)
			if not StateChecker:CheckState(character, "Dashing") then
				dashConnection:Disconnect()
				dashConnection = nil
				return
			end
			local directionVector:Vector3
			
			if not IsShiftLockOff then
				
				local camRight = Vector3.new(character:GetAttribute("CamVectors_CamRight").X, 0, character:GetAttribute("CamVectors_CamRight").Z)
				local camLook = Vector3.new(character:GetAttribute("CamVectors_CamLook").X, 0, character:GetAttribute("CamVectors_CamLook").Z)
				
				if direction == "Right" then
					directionVector = camRight
				elseif direction == "Left" then
					directionVector = -camRight

				elseif direction == "Back" then
					directionVector = -camLook	

				elseif direction == "Forward" then
					directionVector = camLook

				elseif direction == "Forward-Right" then
					directionVector = camLook + camRight

				elseif direction == "Forward-Left" then
					directionVector = camLook - camRight

				elseif direction == "Back-Right" then
					directionVector = -camLook + camRight

				elseif direction == "Back-Left" then
					directionVector = -camLook - camRight
				end
				directionVector = Vector3.new(directionVector.X, 0, directionVector.Z).Unit
			else
				directionVector = Vector3.new(character.HumanoidRootPart.CFrame.LookVector.X, 0, character.HumanoidRootPart.CFrame.LookVector.Z).Unit			
			end
			
			local rayResult = workspace:Raycast(root.Position, directionVector * maxDashDistance * dt, rayParams)
			if rayResult then

			end
			root.CFrame = root.CFrame + (directionVector * maxDashDistance * dt)
		end)
	end)


end