local PathFindingService = game:GetService("PathfindingService")

local StateService = require(game.ReplicatedStorage.Modules.StateService)
local CombatService = require(script.Parent.Parent.ServerModules.CombatService)
local animationsFolder = game.ReplicatedStorage.Assets.Animations
local abilityDataModule = require(game.ReplicatedStorage.Modules.AbilityData)
local AbilityService = require(script.Parent.Parent.ServerModules.AbilityService)
local MovementService = require(script.Parent.Parent.ServerModules.MovementService)
local StateHandler = require(game.ReplicatedStorage.Modules.StateHandler)

local AIService = {}
AIService.__index = AIService
--------------------------------------------------------------------------------------------------------------------------------------
function AIService:CanDash()
	if not self.Target then return false end
	if  self:IsDashPathClear(self.Target.Position) ~= true then return false end
	local distance = (self.Root.Position - self.Target.Position).Magnitude
	if  distance <= self.Config.DetectionRange  and distance >= self.Config.DetectionRange/2 and not
		StateService.checkState(self.NPC,"Stunned", "Blocking", "Attacking", "NoMove", "Dashing",
			"DashCoolDown", "DashEndLag", "FlashStep") then
		return true
	else
		return false
	end
end

function AIService:CanBlock()
	if not self.Target then return false end
	local distance = (self.Root.Position - self.Target.Position).Magnitude
	if StateService.checkState(self.Target.Parent, "Attacking") and distance <= self.Config.AttackRange then
		return true
	else
		return false
	end
end

function AIService:CanUnBlock()
	if not self.Target then return false end
	if StateService.checkState(self.NPC, "Blocking") and not StateService.checkState(self.Target.Parent, "Attacking") and
		self.LastAttackSeenTime > 0  and os.clock() - self.LastAttackSeenTime > 0.25 
	then
		return true
	else
		return false
	end
end


function AIService:CanAttack()
	if not self.Target then return false end
	local distance = (self.Root.Position - self.Target.Position).Magnitude
	if distance <= self.Config.AttackRange then
		return true
	else
		return false
	end
end

function AIService:CanAbility()
	if not self.Target then return false end
	if not StateService.checkState(self.Target.Parent, "Attacking") then
		return  true
	else
		return false
	end
end

function AIService:CanFlashStep()
	if not self.Target then return false end
	local distance = (self.Root.Position - self.Target.Position).Magnitude
	if distance <= self.Config.DetectionRange 
		and distance >= self.Config.DetectionRange/2 
		and (not StateService.checkState(self.NPC,"Stunned", "Blocking", "Attacking", "NoMove", "Dashing",
			"FlashStepEndLag", "FlashStep"))
			and self.FlashStepCharge.Value > 0 then
		return true
	else
		return false
	end
end

function AIService:CanFollow()
	if not self.Target then return false end
	if self.Moving then return false end
	local distance = (self.Root.Position - self.Target.Position).Magnitude
	if distance <= self.Config.DetectionRange then
		return true
	else
		return false
	end
end

function AIService:CanRetreat()
	if self.Humanoid.Health / self.Humanoid.MaxHealth <= 0.1 then
		
		return true
	else
		return false
	end
end

--------------------------------------------------------------------------------------------------------------------------------------
function AIService:EnemyBrain()
	
	if not self.Alive or self.Humanoid.Health <= 0 then
		self:SetState("Dead")
		return
	end

	if not self.Target then
		self.Target = self:AquireTarget()
	end
	
	if not self.Target or not self:IsTargetValid() then
		self.Target = nil
		self:SetState("Idle")
		return
	end

	local distance = (self.Root.Position - self.Target.Position).Magnitude

	---Block---
	if self:CanBlock() then
		self:SetState("Block")
		return
	end
	
	if self:CanUnBlock() then
		self:SetState("UnBlock")
		return
	end
	
	---Ability---
	if self:CanAbility() then
		local bestAbility = nil
		local bestPriority = -math.huge
		local chosenAbility, chosenLetter
		for letter, abilityName in pairs(self.Abilities) do
			local abilityData = abilityDataModule.getAbilityData(abilityName)
			if abilityData then
				if distance <= abilityData.AbilityRange and not StateService.checkState(self.NPC, "Ability"..letter.." Cooldown") then
					local priority = abilityData.Priority or abilityData.Damage or 0
					if priority > bestPriority then
						bestPriority = priority
						bestAbility = {Letter = letter, AbilityData = abilityData}
					end
				end
			end
		end

		if bestAbility then
			chosenAbility = bestAbility
			chosenLetter = bestAbility.Letter
		end

		if chosenAbility then
			self.SelectedAbility = chosenAbility
			self.SelectedAbilityLetter = chosenLetter
			self:SetState("Ability")
			return
		end
	end
	
	---Attack---
	if self:CanAttack() then
		self:SetState("Attack")
		return
	end
	
	---FlashStep---
	if self:CanFlashStep() then
		self:SetState("Flashstep")
		return
	end
	
	---Dash---
	if  self:CanDash() then
		self:SetState("Dash")
		return
	end
	
	---Chase---
	if self:CanFollow() then
		self:SetState("Follow")
		return
	end

	---Default---
	self:SetState("Idle")
	return
end
--------------------------------------------------------------------------------------------------------------------------------------
function AIService:CreateAI(npc ,config, animations, Abilties)
	local self = setmetatable({}, AIService)
	self.NPC = npc
	self.Humanoid = npc:WaitForChild("Humanoid")
	self.Animator = self.Humanoid.Animator
	self.Root = npc:WaitForChild("HumanoidRootPart")
	self.Config = config
	self.Alive = true
	self.CurrentState = "Idle"
	self.FlashStepCharge = npc.Status.FlashStepCharge
	self.AnimationsModule = require(npc.Core.Animations)
	self.AnimationsModule.loadAnims(self.Animator , animationsFolder)
	self.IdleAnimation = self.AnimationsModule.loadedAnimations[animations.Idle]
	self.WalkAnimation = self.AnimationsModule.loadedAnimations[animations.Walk]
	self.RunAnimation  = self.AnimationsModule.loadedAnimations[animations.Run]
	self.Humanoid.WalkSpeed = config.WalkSpeed
	self.LastAttackSeenTime = 0
	self.Abilities = Abilties
	self.Moving = false
	self.LastTargetPos = nil
	
	self.Humanoid.Died:Connect(function()
		self.Alive = false
		self.Target = nil
		self:SetState("Dead")
	end)


	return self
end
--------------------------------------------------------------------------------------------------------------------------------------
function AIService:SetState(stateName)
	local npc = self.NPC

	if self.CurrentState == stateName then return end

	if self.CurrentState then
		StateService.removeState(npc, self.CurrentState)
	end

	StateService.addState(npc, stateName)
	self.CurrentState = stateName
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:UpdateState()
	local npc = self.NPC
	local StateActions = {
		Idle = self.Idle,
		Wander = self.Wander,
		Follow = self.Follow,
		Move = self.Move,
		Attack = self.Attack,
		Block = self.Block,
		UnBlock = self.UnBlock,
		Ability = self.Ability,
		Dash = self.Dash,
		Flashstep = self.Flashstep,
		Dead = self.Dead,
		Retreat = self.Retreat,
	}
	
	if not StateService.checkState(npc, self.CurrentState) then
		StateService.addState(npc, self.CurrentState)
	end
	local action = StateActions[self.CurrentState]
	if action then
		action(self)
	end
	StateHandler:HandleStates(self.NPC)
	print(self.Humanoid.WalkSpeed)
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:IsTargetValid()
	if not self.Target then return false end

	local character = self.Target.Parent
	if not character then return false end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	return true
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:AquireTarget()
	local nearestPlayer = nil
	local closestDist = math.huge

	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (self.Root.Position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance < self.Config.DetectionRange and distance < closestDist then
				nearestPlayer = player.Character.PrimaryPart
				closestDist = distance
			end
		end
	end
	self.Target = nearestPlayer
	return self.Target
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:IsMoving()
	local speed = Vector3.new(self.Root.Velocity.X, 0, self.Root.Velocity.Z).Magnitude
	return speed > 0.1
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:SmartMove(npc, target)
	local targetPosition = target.Position
	targetPosition = Vector3.new(targetPosition.X, npc.Position.Y, targetPosition.Z)
	local npcPosition = npc.Position
	
	self.Moving = true
	
	local path = PathFindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		
	})
	path:ComputeAsync(npcPosition, targetPosition)
	
	if path.Status ~= Enum.PathStatus.Success then
		self.Moving = false
		return
	end
	
	for index,waypoint in  pairs(path:GetWaypoints()) do
		if (waypoint.Position - npc.Position).Magnitude > 3 then
			self.Humanoid:MoveTo(waypoint.Position)

			local reached = false
			local conn:RBXScriptConnection = self.Humanoid.MoveToFinished:Connect(function(success)
				reached = success
			end)

			while not reached do
				local currentPos = Vector3.new(target.Position.X, npc.Position.Y, target.Position.Z)
				if (currentPos - targetPosition).Magnitude > 10 then
					self.Moving = false
					conn:Disconnect()
					return
				end
				task.wait()
			end
			conn:Disconnect()
		end
	end	
	self.Moving = false
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:Idle()
	if self.Alive == false then return end
	if self.CurrentState ~= "Idle" then  return end
	self.RunAnimation:Stop()
	self.WalkAnimation:Stop()
	if not self.IdleAnimation.IsPlaying then	
		self.IdleAnimation:Play()
	end
	
	self.Humanoid.WalkSpeed = 0
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:Wander()
	if self.Alive == false then return end
	if self.Config.Wander == false then  return end
	if self.CurrentState ~= "Wander" then return end
	if not self.WalkAnimation.IsPlaying then
		self.RunAnimation:Stop()
		self.IdleAnimation:Stop()
		self.WalkAnimation:Play()
	end
	self.ArrivalThreshold = self.Humanoid.WalkSpeed * 0.25
	if not self.WanderTarget then
		local radius = self.Config.WanderRadius
		local origin = self.Root.Position
		self.WanderTarget = Vector3.new(
			math.random(-radius, radius),
			0,
			math.random(-radius, radius)
		)
		self.Humanoid:MoveTo(self.WanderTarget)

	end
	if (self.Root.Position - self.WanderTarget).Magnitude < self.ArrivalThreshold then
		self.WalkAnimation:Stop()
		if not self.IdleAnimation.IsPlaying then
			self.IdleAnimation:Play()
		end
		self.Humanoid:Move(Vector3.zero)
		if not self.IsWaiting then
			self.IsWaiting = true
			task.delay(2, function()
				self.IsWaiting = false
				self.WanderTarget = nil
			end)
		end
	end	
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:Follow()
	if self.Alive == false then return end
	if not self.Target then
		self.Target = self:AquireTarget()
	end
	if not self.Target  then return end

	local target = self.Target
	local targetPos
	
	if target:IsA("BasePart") then
		targetPos = target.Position
	elseif target:IsA("Model") and target.PrimaryPart then
		targetPos = target.PrimaryPart.Position
	else
		warn("Invalid follow target")
		return
	end
	
	if self:CanFollow() then
		self.Humanoid.WalkSpeed = self.Config.RunSpeed
		self.WalkAnimation:Stop()
		self.IdleAnimation:Stop()
		if not self.RunAnimation.IsPlaying then
			self.RunAnimation:Play()
		end
		
		if not self.Moving then
			self:SmartMove(self.Root, self.Target)
		end
		
	else
		
		self.Humanoid.WalkSpeed = self.Config.WalkSpeed
		if self:IsMoving()  == false then
			self.RunAnimation:Stop()
			if not self.IdleAnimation.IsPlaying then
				self.IdleAnimation:Play()
			end
		end
	end	
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:Attack()
	if self.Alive == false then return end
	if not self.Target then
	   self.Target = self:AquireTarget()
	end
	if not self.Target  then return end
	
	local targetPos = self.Target.Position

	if self:CanAttack() then
		local forward = self.Root.CFrame.LookVector
		local toTarget = (self.Target.Parent.HumanoidRootPart.Position - self.Root.Position).Unit
		local dot = forward:Dot(toTarget)
		local COS_ANGLE = math.cos(math.rad(45))
		if dot < COS_ANGLE  then
			if not self.RunAnimation.IsPlaying then
				self.RunAnimation:Play()
			end
			self.Humanoid:MoveTo(targetPos)

		else
			self.RunAnimation:Stop()
			CombatService:Attack(self.NPC, self.Config.Tool, nil, self.Config.Damage)
		end
		
	else		
		self.Humanoid:MoveTo(targetPos)
	end
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:Block()
	if self.Alive == false then return end
	if not self.Target then
		self.Target = self:AquireTarget()
	end
	if not self.Target  then return end
	

	
	local targetPos = self.Target.Position
	
	---BlockBroken---
	if self.NPC:FindFirstChild("Status"):FindFirstChild("BlockBroken") then
		CombatService:Block(self.NPC, false, self.Config.Tool)
		self.LastAttackSeenTime = 0

		return
	end	
	
	---Block---
	if self:CanBlock() then
		self.RunAnimation:Stop()
		self.IdleAnimation:Stop()
		self.WalkAnimation:Stop()
		self.LastAttackSeenTime = os.clock()
		CombatService:Block(self.NPC, true, self.Config.Tool)
	end
end

--------------------------------------------------------------------------------------------------------------------------------------
function AIService:UnBlock()
	if self.Alive == false then return end
	if not self.Target then
		self.Target = self:AquireTarget()
	end
	if not self.Target  then return end
	if self:CanUnBlock() then
		CombatService:Block(self.NPC, false , self.Config.Tool)
	end
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:Ability()
	if self.Alive == false then return end
	if not self.Target then
		self.Target = self:AquireTarget()
	end
	if not self.Target  then return end
	
	local targetPos = self.Target.Position
	local distance = (self.Root.Position - targetPos).Magnitude
	
	for letter, ability in pairs(self.Abilities) do
		local abilityData = abilityDataModule.getAbilityData(ability)
		if abilityData then
			if distance <= abilityData.AbilityRange and not StateService.checkState(self.NPC, "Ability"..letter.." Cooldown") then
				AbilityService.AbilityUse(nil, self.NPC, self.Config.Tool,nil,nil, abilityData, letter, self.Config.Damage)
			end
		end
    end	
end

function AIService:IsDashPathClear(targetPos)
	local origin = self.Root.Position
	local maxDistance = 60
	local direction = (targetPos - origin).Unit * maxDistance

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude  -- ignore NPC
	raycastParams.FilterDescendantsInstances = {self.NPC , self.Target.Parent}

	local result = workspace:Raycast(origin, direction, raycastParams)

	if result then
		-- something is blocking the dash
		return false
	else
		-- path is clear
		return true
	end
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:Dash()
	if self.Alive == false then return end
	if not self.Target then
		self.Target = self:AquireTarget()
	end
	if not self.Target  then return end
	local targetPos = self.Target.Position
	local distance = (self.Root.Position - targetPos).Magnitude
	if self:CanDash() then
		self.Humanoid:MoveTo(targetPos)
		MovementService:Dash(nil, "Forward", false, self.Target.Parent, self.NPC)
	end	
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:Flashstep()
	if self.Alive == false then return end
	if not self.Target then
		self.Target = self:AquireTarget()
	end
	if not self.Target then return end
	local targetPos = self.Target.Position
	local distance = (self.Root.Position - targetPos).Magnitude
	if self:CanFlashStep() then
		task.spawn(function()
			if not self.Moving then
				self:SmartMove(self.Root, self.Target)
			end
		end)
		MovementService:FlashStep(self.NPC, self.FlashStepCharge.Value)
		self.FlashStepCharge.Value = self.FlashStepCharge.Value -1
		self.FlashStepCharge.Value = math.clamp(self.FlashStepCharge.Value, 0, 3)
	end	
end

--------------------------------------------------------------------------------------------------------------------------------------
function AIService:Dead()
	self.Humanoid.WalkSpeed = 0
	self.Humanoid:Move(Vector3.zero)

	self.RunAnimation:Stop()
	self.WalkAnimation:Stop()
	self.IdleAnimation:Stop()

	StateService.addState(self.NPC, "Dead")
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:AirJump()
	
end


--------------------------------------------------------------------------------------------------------------------------------------
function AIService:Retreat()
	if self.Alive == false then return end
	if not self.Target then
		self.Target = self:AquireTarget()
	end
	if not self.Target then return end

	-- Get direction away from player
	local retreatDirection = (self.Root.Position - self.Target.Position).Unit -- notice subtraction order
	local retreatDistance = 10 -- studs to move away
	local targetOppPosition = self.Root.Position + retreatDirection * retreatDistance	
	-- Move AI
	self.WalkAnimation:Stop()
	self.IdleAnimation:Stop()
	if not self.RunAnimation.IsPlaying then
		self.RunAnimation:Play()
	end
	self.Humanoid.WalkSpeed = self.Config.RunSpeed
	self.Humanoid:MoveTo(targetOppPosition)
	
end


return AIService
