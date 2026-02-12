local replicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local player = game:GetService("Players").LocalPlayer
local character = script.Parent.Parent
local humanoid:Humanoid = character:WaitForChild("Humanoid")

local modules =  replicatedStorage.Modules
local remotes = replicatedStorage.Remotes
local assets = replicatedStorage.Assets

local stateService = require(modules.StateService)
local ActionVerifier = require(modules.ActionVerifier)
local MovementConfig = require(modules.Configs.MovementConfig)

local DashConfig = MovementConfig.DashConfig
local camera = workspace.CurrentCamera

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

------------------------------------------------------CoreMovementTweaks-----------------------------------------------------

---FOV Changes Based On Current Speed---
local defualtFOV = 70
runService.RenderStepped:Connect(function(dt)
	tweenService:Create(camera, tweenInfo, {FieldOfView = defualtFOV + humanoid.WalkSpeed/2}):Play()
end)






------------------------------------------------------MovementAbilties-------------------------------------------------------

---FlashStepCharges---
flashStepMaxCharge = 3
flashstepCharge = 3
flashstepUI = Instance.new("IntValue")
flashstepUI.Name = "FlashStepCharge"
flashstepUI.Parent = character:WaitForChild("Status")

task.spawn(function()
	while true do
		flashstepCharge = math.clamp(flashstepCharge, 0, flashStepMaxCharge)
		flashstepUI.Value = math.clamp(flashstepCharge, 0, flashStepMaxCharge)
		task.wait(15)
		flashstepCharge += 1
		flashstepCharge = math.clamp(flashstepCharge, 0, flashStepMaxCharge)
		flashstepUI.Value = math.clamp(flashstepCharge, 0, flashStepMaxCharge)
	end
end)

---AirJumpCharges---
airJumpMaxCharge = 3
airJumpCharge = 3

runService.Heartbeat:Connect(function()
	if humanoid.FloorMaterial ~= Enum.Material.Air then
		airJumpCharge = airJumpMaxCharge
	end
end)

local function getDashDirection()
	local keysPressed = UserInputService:GetKeysPressed()
	local dashDirection =  nil
	for _, input:InputObject in keysPressed do
		if input.KeyCode == Enum.KeyCode.W then
			return  "Forward"
		end
		if input.KeyCode == Enum.KeyCode.A then
			return "Left"
		end
		if input.KeyCode == Enum.KeyCode.S then
			return "Back"
		end
		if input.KeyCode == Enum.KeyCode.D then
			return "Right"
		end
	end
end

UserInputService.InputBegan:Connect(function(input)
	
	------Sprinting------
	if input.KeyCode == Enum.KeyCode.LeftShift then
		---Start Sprinting---
		if not stateService.checkState(character, "Sprinting") then
			stateService.addState(character, "Sprinting")
			---Stop Sprinting---
		else
			stateService.removeState(character, "Sprinting")
		end   	
	end
	
	------Dashing & FlashStep------
	if input.KeyCode == Enum.KeyCode.Q  then
		---FlashStep---
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and ActionVerifier:CanFlashstep(character, flashstepCharge) then
			remotes.FlashStep:FireServer(flashstepCharge)
			flashstepCharge -= 1
			flashstepCharge = math.clamp(flashstepCharge, 0, flashStepMaxCharge)
			flashstepUI.Value = math.clamp(flashstepCharge, 0, flashStepMaxCharge)
		else
			---Dashing---
			local direction = getDashDirection()
			if direction and ActionVerifier:CanDash(character) then
				local IsShiftLockOff = UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter
				local character = player.Character or player.CharacterAdded:Wait()
				remotes.Dash:FireServer(direction, IsShiftLockOff)
			end	
		end
	end
	
	---WallRun---
	--[[if input.KeyCode == Enum.KeyCode.Space then
		if ActionVerifier:CanWallRun(character) then
			remotes.WallRun:FireServer()
		end
	end
	
	---AirJump---
	if input.KeyCode == Enum.KeyCode.Space then
		if humanoid:GetState()  == Enum.HumanoidStateType.Freefall then
			if not stateService.checkState(character,"Stunned", "Blocking", "Attacking", "NoMove", "Dashing",
				"FlashStepEndLag", "FlashStep", "AirJump") and airJumpCharge > 0 then
				remotes.AirJump:FireServer(airJumpCharge)
				airJumpCharge -= 1
			end
		end
	end
	--]]
end)


---Dash Movement---
local dashConnection
remotes.Dash.OnClientEvent:Connect(function(direction)
	---Dash Movement---	
	local maxDashDistance = DashConfig.MaxDashDistance
	local root:Part? = character:FindFirstChild("HumanoidRootPart")

	local camLook = character:FindFirstChild("CamLookVector")
	local camRight = character:FindFirstChild("CamRightVector")

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {character}

	if dashConnection then
		dashConnection:Disconnect()
		dashConnection = nil
	end
	dashConnection = runService.Heartbeat:Connect(function(dt)
		if not stateService.checkState(character, "Dashing") then
			stateService.addState(character, "DashCoolDown", DashConfig.DashCooldown)
			dashConnection:Disconnect()
			dashConnection = nil
			return
		end
		local directionVector:Vector3

		if direction == "Right" then
			directionVector = camRight.Value
		elseif direction == "Left" then
			directionVector = -camRight.Value

		elseif direction == "Back" then
			directionVector = -camLook.Value

		elseif direction == "Forward" then
			directionVector = camLook.Value

		end

		local rayResult = workspace:Raycast(root.Position, directionVector * maxDashDistance * dt * 2, rayParams)
		if rayResult then
			stateService.removeState(character, "Dashing")
		end
		root.CFrame = root.CFrame + (directionVector * maxDashDistance * dt)
	end)
end)

