local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Character = require(ReplicatedStorage.Modules.Client.Character)

local assets = ReplicatedStorage.Assets
local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local StateService = require(game.ServerScriptService.Services.Core.StateService)
local ActionVerifier = require(game.ReplicatedStorage.Modules.Helpers.ActionVerifier)
local MovementConfig = require(game.ReplicatedStorage.Modules.Configs.MovementConfig)

local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)
local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)

local DashConfig = MovementConfig.DashConfig
local wallJumpConfig = MovementConfig.WallRunConfig
local flashStepConfig = MovementConfig.FlashstepConfig

local MovementService = {}

function MovementService:LoadSharedAnimations()
	game.Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			local animator = humanoid.Animator
			Animations:loadAnims(animator, assets.Shared)
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

function MovementService:Dash(player, direction: Vector3?, IsShiftLockOff, npcTarget, npc)
	local character = npc
	if not npc then
		character = player.Character or player.CharacterAdded:Wait()
	end

	if not ActionVerifier:CanDash(character) then
		return
	end

	local humanoid = character:WaitForChild("Humanoid")
	local directionName

	if IsShiftLockOff or npcTarget then
		local dashAnim: AnimationTrack = Animations:GetAnimation(humanoid.Animator, "Shared.Animations.Dashes.Forward")

		StateService:AddState(character, "Dashing", dashAnim.Length)
		---Animation---
		dashAnim:Play()

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

		if angle > -22.5 and angle <= 22.5 then
			directionName = "Forward"
		elseif angle > 22.5 and angle <= 67.5 then
			directionName = "Forward-Right"
		elseif angle > 67.5 and angle <= 112.5 then
			directionName = "Right"
		elseif angle > 112.5 and angle <= 157.5 then
			directionName = "Back-Right"
		elseif angle > 157.5 or angle <= -157.5 then
			directionName = "Back"
		elseif angle > -157.5 and angle <= -112.5 then
			directionName = "Back-Left"
		elseif angle > -112.5 and angle <= -67.5 then
			directionName = "Left"
		elseif angle > -67.5 and angle <= -22.5 then
			directionName = "Forward-Left"
		end

		local dashAnim: AnimationTrack =
			Animations:GetAnimation(humanoid.Animator, "Shared.Animations.Dashes." .. directionName)

		StateService:AddState(character, "Dashing", dashAnim.Length)
		---Animation---
		dashAnim:Play()
		dashAnim.Looped = false

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

	---If NPC---
	if npcTarget then
		---Dash Movement---
		local maxDashDistance = DashConfig.MaxDashDistance
		local root: Part = character:FindFirstChild("HumanoidRootPart")

		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		rayParams.FilterDescendantsInstances = { character }

		Connections:AddConnection(
			character,
			"Character",
			"Dash",
			RunService.Heartbeat:Connect(function(dt)
				if not StateChecker:CheckState(character, "Dashing") then
					StateService:AddState(character, "DashCoolDown", DashConfig.DashCooldown)
					Connections:RemoveConnection(character, "Character", "Dash")
					return
				end
				local directionVector: Vector3

				local targetRoot = npcTarget.HumanoidRootPart
				directionVector = targetRoot.Position - root.Position
				directionVector = Vector3.new(directionVector.X, 0, directionVector.Z).Unit

				local rayResult =
					workspace:Raycast(root.Position, directionVector * maxDashDistance * dt * 2, rayParams)
				if rayResult then
					Connections:RemoveConnection(Character, "Character", "Dash")
					StateService:RemoveState(character, "Dashing")
				end
				root.CFrame = root.CFrame + (directionVector * maxDashDistance * dt)
			end)
		)
	else
		---If Player Then Let Client Handle Movement---
		NetworkingService:FireToClient(player, "Dash", directionName, IsShiftLockOff)
	end
	Connections:AddConnection(
		character,
		"Character",
		"DashCD",
		RunService.Heartbeat:Connect(function()
			if not StateChecker:CheckState(character, "Dashing") then
				Connections:RemoveConnection(character, "Character", "DashCD")
				StateService:AddState(character, "DashCoolDown", DashConfig.DashCooldown)
			end
		end)
	)
end

function MovementService:FlashStep(character)
	local playerFlashStep = CharacterVitalsService:GetVital(character, "FlashStep")
	local flashstepCharge = playerFlashStep.CurrentFlashStep
	if not ActionVerifier:CanFlashstep(character, flashstepCharge) then
		return
	end
	local statusFolder = character:WaitForChild("Status")

	StateService:AddState(character, "Invulnerable", flashStepConfig.FlashstepDuration)
	StateService:AddState(character, "FlashStep", flashStepConfig.FlashstepDuration)

	CharacterVitalsService:ModifyVital(character, "Movement", "ModifyFlashStep", {
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
