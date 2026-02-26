local repstor = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local runService = game:GetService("RunService")

local assets = repstor.Assets
local stateService = require(repstor.Modules.StateService)
local ActionVerifier =  require(repstor.Modules.ActionVerifier)
local MovementConfig = require(repstor.Modules.Configs.MovementConfig)
local itemDataBase = require(repstor.Modules.Data.ItemDataBase)

local animsModule = require(repstor.Modules.Animations)
local CharacterVitalsService = require(script.Parent.CharacterVitalsService)

local DashConfig = MovementConfig.DashConfig
local wallJumpConfig = MovementConfig.WallRunConfig
local flashStepConfig = MovementConfig.FlashstepConfig

local MovementService = {}

function MovementService:LoadSharedAnimations()
	game.Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			local animator = humanoid.Animator
			animsModule:loadAnims(animator, assets.Shared)
		end)
	end)
end

function MovementService:Sprint(character)
	if not stateService.checkState(character, "Sprinting") then
		stateService.addState(character, "Sprinting")
		---Stop Sprinting---
	else
		stateService.removeState(character, "Sprinting")
	end 
end

function MovementService:Dash(player:Player, direction:Vector3? , IsShiftLockOff, npcTarget, npc)
	local character = npc
	if not npc then
		character = player.Character or player.CharacterAdded:Wait()
	end
		
	if not ActionVerifier:CanDash(character) then return end
	
	local humanoid:Humanoid = character:WaitForChild("Humanoid")
	local statusFolder = character:WaitForChild("Status")
	
	if IsShiftLockOff or npcTarget then
		local dashAnim:AnimationTrack? = animsModule:GetAnimation(humanoid.Animator, "Shared.Animations.Dashes.Forward")
		
		local dashing = stateService.addState(character, "Dashing", dashAnim.Length)
		---Animation---
		dashAnim:Play()

		---VFX---
		repstor.Remotes.ClientEffects:FireAllClients("DashVFX",
			{
				["Direction"] = "Forward",
				["Character"] = character,
				["DashTime"] = dashAnim.Length,
			}
		)
	else
		local rightDot = direction:Dot(character.HumanoidRootPart.CFrame.RightVector)
		local forwardDot = direction:Dot(character.HumanoidRootPart.CFrame.LookVector)

		local angle = math.atan2(rightDot, forwardDot)
		angle = math.deg(angle)

		if angle > -22.5 and angle <= 22.5 then
			direction = "Forward"
		elseif angle > 22.5 and angle <= 67.5 then
			direction = "Forward-Right"
		elseif angle > 67.5 and angle <= 112.5 then
			direction = "Right"
		elseif angle > 112.5 and angle <= 157.5 then
			direction = "Back-Right"
		elseif angle > 157.5 or angle <= -157.5 then
			direction = "Back"
		elseif angle > -157.5 and angle <= -112.5 then
			direction = "Back-Left"
		elseif angle > -112.5 and angle <= -67.5 then
			direction = "Left"
		elseif angle > -67.5 and angle <= -22.5 then
			direction = "Forward-Left"
		end
				
		local dashAnim:AnimationTrack? = animsModule:GetAnimation(humanoid.Animator,"Shared.Animations.Dashes."..direction)
				
		local dashing = stateService.addState(character, "Dashing", dashAnim.Length)
		---Animation---
		dashAnim:Play()

		---VFX---
		repstor.Remotes.ClientEffects:FireAllClients("DashVFX",
			{
				["Direction"] = direction,
				["Character"] = character,
				["DashTime"] = dashAnim.Length,
			}
		)
	end
	
	---Sound---
	repstor.Remotes.ClientEffects:FireAllClients("Sound",
		{
			["SoundName"] = "Shared.Sounds.Dash",
			["Parent"] = humanoid,	
		}
	)
	
	
	---If NPC---
	if npcTarget then
		---Dash Movement---	
		local maxDashDistance = DashConfig.MaxDashDistance
		local root:Part? = character:FindFirstChild("HumanoidRootPart")

		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		rayParams.FilterDescendantsInstances = {character}
		
		local dashConnection = nil
		dashConnection = runService.Heartbeat:Connect(function(dt)

			if not stateService.checkState(character, "Dashing") then
				stateService.addState(character, "DashCoolDown", DashConfig.DashCooldown)
				dashConnection:Disconnect()
				dashConnection = nil
				return
			end
			local directionVector:Vector3
			
			local targetRoot = npcTarget.HumanoidRootPart
			directionVector = targetRoot.Position - root.Position
			directionVector = Vector3.new(directionVector.X, 0, directionVector.Z).Unit

			local rayResult = workspace:Raycast(root.Position, directionVector * maxDashDistance * dt * 2, rayParams)
			if rayResult then
				stateService.removeState(character, "Dashing")
			end
			root.CFrame = root.CFrame + (directionVector * maxDashDistance * dt)

		end)	
	else
		---If Player Then Let Client Handle Movement---
		repstor.Remotes.Dash:FireClient(player, direction, IsShiftLockOff)
	end
end

function MovementService:FlashStep(character)
	local playerFlashStep = CharacterVitalsService:GetVital(character, "FlashStep")
	local flashstepCharge = playerFlashStep.CurrentFlashStep
	local maxFlashstepCharge = playerFlashStep.MaxFlashStep
	if not ActionVerifier:CanFlashstep(character, flashstepCharge) then return end

	local statusFolder = character:WaitForChild("Status")
	local humanoid = character:WaitForChild("Humanoid")
		
	stateService.addState(character, "Invulnerable", flashStepConfig.FlashstepDuration)
	stateService.addState(character, "FlashStep", flashStepConfig.FlashstepDuration)
	
	
	CharacterVitalsService:ModifyVital(character, "Movement", "ModifyFlashStep", {
		["FlashStepChange"] = -1
	})
	
	if statusFolder:FindFirstChild("FlashStep") then
		task.delay(flashStepConfig.FlashstepDuration, function()
			stateService.addState(character, "FlashStepEndLag", flashStepConfig.FlashstepEndlag)
		end)
		
		---VFX---
		repstor.Remotes.ClientEffects:FireAllClients("FlashstepVFX",
			{
				["Character"] = character,
			}
		)
		
		---Sound---
		repstor.Remotes.ClientEffects:FireAllClients("Sound",
			{
				["SoundName"] = "Shared.Sounds.FlashStep",
				["Parent"] = humanoid,
			}
		)
	
	end	
	return flashstepCharge
end

function MovementService:WallRun(character)
	if not ActionVerifier:CanWallRun(character) then return end
	if stateService.checkState(character, "WallRunning") then return end
	local root:Part? = character:WaitForChild("HumanoidRootPart")

	stateService.addState(character, "WallRunning")
	
	local wallRunSpeed = wallJumpConfig.WalkRunSpeed
	local stickForce = wallJumpConfig.StickForce
	local maxDuration = wallJumpConfig.MaxDuration
	local elapsed = 0
	local currentTangent
	
	local connection
	connection = runService.Heartbeat:Connect(function(dt)
		if not stateService.checkState(character , "WallRunning") then return end
		
		elapsed = elapsed + dt
		if elapsed >= maxDuration then
			stateService.removeState(character, "WallRunning")
			connection:Disconnect()
			return
		end
		
		local hitNormal
		local hitRotation
		local directions = {
			root.CFrame.LookVector,
			root.CFrame.RightVector,
			-root.CFrame.RightVector
		}
		
		for _,direction in pairs(directions) do
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {character}
			local ray = workspace:Raycast(root.Position, direction*3, params)
			if ray then
				hitNormal = ray.Normal
				break
			end
		end	
		
		if not hitNormal then 
			stateService.removeState(character, "WallRunning")
			connection:Disconnect()
			connection = nil
			return 
		end
		
		
	end)	
end

function MovementService:AirJump(character, AirJumpCharges:number)
	
	if not ActionVerifier:CanAirJump(character, AirJumpCharges) then return end
	
	local statusFolder = character:WaitForChild("Status")
	local humanoid:Humanoid = character:WaitForChild("Humanoid")
	local hrp = character:WaitForChild("HumanoidRootPart")

	if humanoid:GetState()  == Enum.HumanoidStateType .Freefall then
		
		local AirJump = stateService.addState(character, "AirJump", 0.25)
		
		local AirJumpSound = assets.Shared.Sounds.AirJump:Play()

		local attachment = Instance.new("Attachment")
		attachment.Name = "Attachment"
		attachment.Parent = hrp
		local linVel = Instance.new("LinearVelocity")
		linVel.Parent = hrp
		linVel.Attachment0  = attachment
		linVel.RelativeTo = Enum.ActuatorRelativeTo.World
		linVel.MaxForce = math.huge
		linVel.VectorVelocity = Vector3.new(0,80,0)

		game:GetService("Debris"):AddItem(linVel, 0.025)
		game:GetService("Debris"):AddItem(attachment, 0.025)
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

	end
	return AirJumpCharges
end


return MovementService
