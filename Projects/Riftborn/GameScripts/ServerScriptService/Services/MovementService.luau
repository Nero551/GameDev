local repstor = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local runService = game:GetService("RunService")

local assets = repstor.Assets
local animationsFolder = assets.Shared.Animations
local stateService = require(repstor.Modules.StateService)
local ActionVerifier =  require(repstor.Modules.ActionVerifier)
local MovementConfig = require(repstor.Modules.Configs.MovementConfig)
local itemDataBase = require(repstor.Modules.Data.ItemDataBase)

local animsModule = require(repstor.Modules.Animations)

local DashConfig = MovementConfig.DashConfig
local wallJumpConfig = MovementConfig.WallRunConfig
local flashStepConfig = MovementConfig.FlashstepConfig

local MovementService = {}

local function StopMainStateAnimations(current, Type, character)
	for animName,anim in pairs(animsModule.loadedAnimations[character]) do
		if string.find(animName, "Animations."..Type)  then
			if anim ~= current and anim.IsPlaying then
				anim:Stop(0.2)
			end	
		end
	end
end

---MainStateAnimations---

function MovementService:MainStates()
	game.Players.PlayerAdded:Connect(function(player)
		
		local currentIdle:Animation?
		local currentRun:Animation?
		local currentWalk:Animation?
		
		local conn:RBXScriptConnection?
		
		conn = runService.Heartbeat:Connect(function(dt)
			local char = player.Character or player.CharacterAdded:Wait()

			if stateService.checkState(char, "Dead") then
				conn:Disconnect()
				conn = nil
			end
			
	
			local humanoid = char:WaitForChild("Humanoid")
			local animator = humanoid.Animator
			
			local tool = char:FindFirstChildWhichIsA("Tool")
			
			if tool then
				local weaponData = itemDataBase:GetItemData(tool:GetAttribute("ID"))
				if weaponData then
					
					currentIdle = animsModule:GetAnimation(animator, "Weapons."..tool.Name..".Animations.Idle")
					currentRun = animsModule:GetAnimation(animator, "Weapons."..tool.Name..".Animations.Run")
					currentWalk = animsModule:GetAnimation(animator, "Weapons."..tool.Name..".Animations.Walk")
				end
				
			else
					
				currentIdle = animsModule:GetAnimation(animator, "Shared.Animations.Idle.Default")
				currentRun = animsModule:GetAnimation(animator, "Shared.Animations.Run.Default")
				currentWalk = animsModule:GetAnimation(animator, "Shared.Animations.Walk.Default")
			end
			
			
			---Jump Animation---
			if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
				animsModule:GetAnimation(humanoid.Animator, "Shared.Animations.Jump.Jump"):Play()
			else
				animsModule:GetAnimation(humanoid.Animator, "Shared.Animations.Jump.Jump"):Stop()
			end

			---Falling Animation---
			if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
				animsModule:GetAnimation(humanoid.Animator, "Shared.Animations.Fall.Fall"):Play()
			else
				animsModule:GetAnimation(humanoid.Animator, "Shared.Animations.Fall.Fall"):Stop()
			end

			---Landing Animation---
			if humanoid:GetState() == Enum.HumanoidStateType.Landed then
			end
			
			
			if humanoid:GetState() == Enum.HumanoidStateType.Jumping or  humanoid:GetState() == Enum.HumanoidStateType.Freefall or 
				humanoid:GetState() == Enum.HumanoidStateType.Landed then

				for name, anim in animsModule.loadedAnimations[char] do
					if string.find(name, "Animations.Run") or string.find(name , "Animations.Idle") or string.find(name, "Animations.Walk") then
						if anim.IsPlaying then
							anim:Stop(0.2)
						end
					end
				end
				return
			end
			
			---Idle--
			if  humanoid.MoveDirection.Magnitude <=  0 then
				StopMainStateAnimations(currentIdle, "Idle", char)
				
				if not currentIdle.IsPlaying  then					
					currentIdle:Play(0.2)
					currentWalk:Stop(0.2)
					currentRun:Stop(0.2)
				end
				
				---Sprint---
			elseif	stateService.checkState(char,"Sprinting") and ActionVerifier:CanSprint(char) then				
				StopMainStateAnimations(currentRun, "Run", char)
				
				if not currentRun.IsPlaying then
					currentRun:Play(0.2)
					currentWalk:Stop(0.2)
					currentIdle:Stop(0.2)
				end
				
				
				---Walk---
			elseif	ActionVerifier:CanWalk(char) then	
				StopMainStateAnimations(currentWalk, "Walk", char)
			
				if not currentWalk.IsPlaying then
					currentWalk:Play(0.2)
					currentRun:Stop(0.2)
					currentIdle:Stop(0.2)
				end
			end
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

function MovementService:Dash(player:Player, direction , IsShiftLockOff, npcTarget, npc)
	local character = npc
	if not npc then
		character = player.Character or player.CharacterAdded:Wait()
	end
		
	if not ActionVerifier:CanDash(character) then return end
	
	local core = character:WaitForChild("Core")
	local humanoid:Humanoid = character:WaitForChild("Humanoid")
	local animsModule = require(repstor.Modules.Animations)
	local statusFolder = character:WaitForChild("Status")
	
	
	animsModule:loadAnims(humanoid.Animator ,  animationsFolder.Client)
	
	if  npcTarget then
		direction = "Forward"
	end
	
	if IsShiftLockOff then
		local dashTime = animsModule.loadedAnimations[character]["Client.Dashes.Forward"].Length
		
		local dashing = stateService.addState(character, "Dashing", dashTime)
		---Animation---
		animsModule.loadedAnimations[character]["Client.Dashes.Forward"]:Play()

		---VFX---
		repstor.Remotes.ClientEffects:FireAllClients("DashVFX",
			{
				["Direction"] = "Forward",
				["Character"] = character,
				["DashTime"] = dashTime,
			}
		)
	else
		local dashTime = animsModule.loadedAnimations["Client.Dashes."..direction].Length
		
		local dashing = stateService.addState(character, "Dashing", dashTime)
		---Animation---
		animsModule.loadedAnimations["Client.Dashes."..direction]:Play()

		---VFX---
		repstor.Remotes.ClientEffects:FireAllClients("DashVFX",
			{
				["Direction"] = direction,
				["Character"] = character,
				["DashTime"] = dashTime,
			}
		)
	end
	
	---Sound---
	repstor.Remotes.ClientEffects:FireAllClients("Sound",
		{
			["SoundName"] = "Dash",
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


		local dashConnection
		dashConnection = runService.Heartbeat:Connect(function(dt)

			if not stateService.checkState(character, "Dashing") then
				stateService.addState(character, "DashCoolDown", DashConfig.DashCooldown)
				dashConnection:Disconnect()
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
		repstor.Remotes.Dash:FireClient(player, direction)
	end
end

function MovementService:FlashStep(character, flashstepCharge:number)
	
	if not ActionVerifier:CanFlashstep(character, flashstepCharge) then return end


	
	local statusFolder = character:WaitForChild("Status")
	local humanoid = character:WaitForChild("Humanoid")
	
	stateService.addState(character, "Invulnerable", flashStepConfig.FlashstepDuration)
	stateService.addState(character, "FlashStep", flashStepConfig.FlashstepDuration)
	
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
				["SoundName"] = "FlashStep",
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
		
		local AirJumpSound = assets.Sounds.AirJump:Play()

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
