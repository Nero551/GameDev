return function(npc)
	local PathfindingService = game:GetService("PathfindingService")
	local StateService = require(game.ServerScriptService.Services.Core.StateService)
	
	local AIService = require(game.ServerScriptService.Services.NPC.AIService)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	local humanoid:Humanoid = npc:WaitForChild("Humanoid")

	if not AIData.Target then return end
	
	StateService:AddState(npc, "Sprinting")
		
	if AIData.IdleAnimation.IsPlaying then
		AIData.IdleAnimation:Stop()
	end
	
	if AIData.WalkAnimation.IsPlaying then
		AIData.WalkAnimation:Stop()
	end
	
	if not AIData.RunAnimation.IsPlaying then
		AIData.RunAnimation:Play()
	end
	
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		WaypointSpacing = 5,
	})
	if os.clock() - AIData.NeedsRepath > 2 then
		AIData.Moving = false 
		AIData.NeedsRepath = 0
	end
	if not AIData.Moving  then
		AIData.NeedsRepath = os.clock()
		AIData.Moving = true
		
		path:ComputeAsync(AIData.Root.Position, AIData.Target.Position)
		
		if path.Status ~= Enum.PathStatus.Success then
			AIData.Moving = false
			AIData.NeedsRepath = 0
			print("Path Failed")
			return
		end
		
		local originalTargetPos
		if AIData.Target then
			 originalTargetPos = AIData.Target.Position
		end
		
		for _,waypoint:PathWaypoint in ipairs(path:GetWaypoints()) do
			
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
			end
			
			if (waypoint.Position - AIData.Root.Position).Magnitude > 5 then
				
				if not AIData.Target then break end
				
				-- local part = Instance.new("Part")
				-- part.Material = "Neon"
				-- part.Anchored = true
				-- part.CanCollide = false
				-- part.Shape = "Ball"
				-- part.Position = waypoint.Position
				-- part.Parent = workspace.World.PathFinding
				-- game.Debris:AddItem(part, 5)
				
				if (originalTargetPos - AIData.Target.Position).Magnitude > 8 or os.clock() - AIData.NeedsRepath  > 4 then
					break
				end
				humanoid:MoveTo(waypoint.Position)
				local reached = humanoid.MoveToFinished:Wait()
				if not reached then
   					break
				end
			end
		end
		AIData.NeedsRepath = 0
		AIData.Moving = false
	end
end
