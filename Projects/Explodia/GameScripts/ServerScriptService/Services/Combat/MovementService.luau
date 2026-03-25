local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local assets = ReplicatedStorage.Assets
local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local StateService = require(game.ServerScriptService.Services.Core.StateService)
local ActionVerifier = require(game.ReplicatedStorage.Modules.Helpers.ActionVerifier)
local MovementConfig = require(game.ReplicatedStorage.Modules.Configs.MovementConfig)

local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

local DashConfig = MovementConfig.DashConfig
local wallJumpConfig = MovementConfig.WallRunConfig
local flashStepConfig = MovementConfig.FlashstepConfig

local MovementService = {}

function MovementService:LoadSharedAnimations()
	game.Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			Animations:LoadAnimations(humanoid, assets.Shared)
		end)
	end)
end

function MovementService:Sprint(character)
	if not StateChecker:CheckState(character, "Sprinting") then
		StateService:AddState(character, "Sprinting")
		---Stop Sprinting---
	else
		StateService:RemoveState(character, "Sprinting")
	end
end

function MovementService:Dash(character, direction: Vector3, shiftLockState)
	if not ActionVerifier:CanDash(character) then
		return
	end

	local player = Players:GetPlayerFromCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	local directionName

	if shiftLockState == 0 or not player then
		---Animation---
		local dashAnim: AnimationTrack = Animations:GetAnimation(humanoid, "Shared.Animations.Dashes.Forward")
		dashAnim:Play()
		dashAnim:AdjustSpeed(2)
		dashAnim.Looped = false
		StateService:AddState(character, "Dashing", dashAnim.Length / 2)
		---VFX---
		NetworkingService:FireInRange("ClientEffects", character.HumanoidRootPart.Position, nil, "DashVFX", {
			["Dir"] = "Forward",
			["HRP"] = character.HumanoidRootPart,
			["DashT"] = dashAnim.Length,
		})
	else
		if direction == nil then
			return
		end

		local rightDot = direction:Dot(character.HumanoidRootPart.CFrame.RightVector)
		local forwardDot = direction:Dot(character.HumanoidRootPart.CFrame.LookVector)

		local angle = math.atan2(rightDot, forwardDot)
		angle = math.deg(angle)

		if angle >= -22.5 and angle <= 22.5 then
			directionName = "Forward"
		elseif angle > 22.5 and angle < 67.5 then
			directionName = "Forward-Right"
		elseif angle >= 67.5 and angle <= 112.5 then
			directionName = "Right"
		elseif angle > 112.5 and angle < 157.5 then
			directionName = "Back-Right"
		elseif angle >= 157.5 or angle <= -157.5 then
			directionName = "Back"
		elseif angle > -157.5 and angle < -112.5 then
			directionName = "Back-Left"
		elseif angle >= -112.5 and angle <= -67.5 then
			directionName = "Left"
		elseif angle > -67.5 and angle < -22.5 then
			directionName = "Forward-Left"
		end

		---Animation---
		local dashAnim: AnimationTrack = Animations:GetAnimation(humanoid, "Shared.Animations.Dashes." .. directionName)
		dashAnim:Play()
		dashAnim:AdjustSpeed(2)
		dashAnim.Looped = false
		StateService:AddState(character, "Dashing", dashAnim.Length / 2)

		---VFX---
		NetworkingService:FireInRange("ClientEffects", character.HumanoidRootPart.Position, nil, "DashVFX", {
			["Dir"] = directionName,
			["HRP"] = character.HumanoidRootPart,
			["DashT"] = dashAnim.Length,
		})
	end

	---Sound---
	NetworkingService:FireInRange("ClientEffects", character.HumanoidRootPart.Position, nil, "Sound", {
		["Sound"] = assets.Shared.Sounds.Dash,
	})

	local dashVelocity = Instance.new("LinearVelocity")
	local root = character:FindFirstChild("HumanoidRootPart")
	dashVelocity.MaxForce = math.huge
	dashVelocity.Attachment0 = root:FindFirstChildWhichIsA("Attachment") or Instance.new("Attachment", root)
	dashVelocity.Parent = root

	Connections:AddConnection(
		character,
		"Character",
		"Dash",
		RunService.Heartbeat:Connect(function(dt)
			if not StateChecker:CheckState(character, "Dashing") then
				dashVelocity:Destroy()
				StateService:AddState(character, "DashCoolDown", DashConfig.DashCooldown)
				Connections:RemoveConnection(character, "Character", "Dash")
				return
			end
			print(StateService.Status[character].Dashing.Duration)

			if player then
				if shiftLockState == 0 then
					dashVelocity.VectorVelocity = character.HumanoidRootPart.CFrame.LookVector
						* DashConfig.StudsPerSecond
				else
					local forward = character.HumanoidRootPart.CFrame.LookVector
					local right = character.HumanoidRootPart.CFrame.RightVector

					forward = Vector3.new(forward.X, 0, forward.Z).Unit
					right = Vector3.new(right.X, 0, right.Z).Unit


					local forwardDot = direction:Dot(forward)
					local rightDot = direction:Dot(right)

					local finalDir = (forward * forwardDot + right * rightDot)

					if finalDir.Magnitude > 0 then
						finalDir = finalDir.Unit
					end

					dashVelocity.VectorVelocity = finalDir * DashConfig.StudsPerSecond
				end
			else
				dashVelocity.VectorVelocity = Vector3.new(
					(direction - root.Position).X,
					0,
					(direction - root.Position).Z
				).Unit * DashConfig.StudsPerSecond
			end
		end)
	)
end

function MovementService:FlashStep(character)
	local playerFlashStep = VitalsService:GetVital(character, "FlashStep")
	local flashstepCharge = playerFlashStep.CurrentFlashStep
	if not ActionVerifier:CanFlashstep(character, flashstepCharge) then
		return
	end
	local statusFolder = character:WaitForChild("Status")

	StateService:AddState(character, "Invulnerable", flashStepConfig.FlashstepDuration)
	StateService:AddState(character, "FlashStep", flashStepConfig.FlashstepDuration)

	VitalsService:ModifyVital(character, "Movement", "ModifyFlashStep", {
		["FlashStepChange"] = -1,
	})

	if statusFolder:FindFirstChild("FlashStep") then
		task.delay(flashStepConfig.FlashstepDuration, function()
			StateService:AddState(character, "FlashStepEndLag", flashStepConfig.FlashstepEndlag)
		end)

		---VFX---
		NetworkingService:FireInRange("ClientEffects", character.HumanoidRootPart.Position, nil, "FlashstepVFX", {
			["Character"] = character,
		})

		---Sound---
		NetworkingService:FireInRange("ClientEffects", character.HumanoidRootPart.Position, nil, "Sound", {
			["Sound"] = assets.Shared.Sounds.FlashStep,
		})
	end
	return flashstepCharge
end

function MovementService:WallRun(character)
	if not ActionVerifier:CanWallRun(character) then
		return
	end
	if StateChecker:CheckState(character, "WallRunning") then
		return
	end
	local root: Part = character:WaitForChild("HumanoidRootPart")

	StateService:AddState(character, "WallRunning")

	local maxDuration = wallJumpConfig.MaxDuration
	local elapsed = 0

	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		if not StateChecker:CheckState(character, "WallRunning") then
			return
		end

		elapsed = elapsed + dt
		if elapsed >= maxDuration then
			StateService:RemoveState(character, "WallRunning")
			connection:Disconnect()
			return
		end

		local hitNormal
		local directions = {
			root.CFrame.LookVector,
			root.CFrame.RightVector,
			-root.CFrame.RightVector,
		}

		for _, direction in pairs(directions) do
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { character }
			local ray = workspace:Raycast(root.Position, direction * 3, params)
			if ray then
				hitNormal = ray.Normal
				break
			end
		end

		if not hitNormal then
			StateService:RemoveState(character, "WallRunning")
			connection:Disconnect()
			connection = nil
			return
		end
	end)
end

return MovementService
