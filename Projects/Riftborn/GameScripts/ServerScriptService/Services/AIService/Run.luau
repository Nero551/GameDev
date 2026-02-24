

return function(npc)
	local PathFindingService = game:GetService("PathfindingService")
	
	local AIService = require(script.Parent)
	local CharacterVitalsService = require(script.Parent.Parent.Parent.Services.CharacterVitalsService)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then 
		AIData.Moving = false
		return 
	end
	local humanoid:Humanoid = npc:WaitForChild("Humanoid")

	if not AIData.Target then
		AIData.Moving = false
		return
	end
	
	CharacterVitalsService:ModifyVital(npc, "Movement", "ModifyWalkSpeed", {
		["WalkSpeed"] = AIData.RunSpeed	
	})
		
	if AIData.IdleAnimation.IsPlaying then
		AIData.IdleAnimation:Stop()
	end
	
	if AIData.WalkAnimation.IsPlaying then
		AIData.WalkAnimation:Stop()
	end
	
	if not AIData.RunAnimation.IsPlaying then
		AIData.RunAnimation:Play()
	end
	
	local path = PathFindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		WaypointSpacing = 4,
	})
	
	if not AIData.Moving then
		AIData.Moving = true
		local needsRepath = os.clock()
		
		path:ComputeAsync(AIData.Root.Position, AIData.Target.Position)
		
		if path.Status ~= Enum.PathStatus.Success then
			AIData.Moving = false
			print("Path Failed")
			return
		end
		
		local originialTargetPos = AIData.Target.Position
		
		for _,waypoint:PathWaypoint in ipairs(path:GetWaypoints()) do
			
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
			
			if (waypoint.Position - AIData.Root.Position).Magnitude > 5 then
				
				if not AIData.Target then break end
				
				local part = Instance.new("Part")
				part.Material = "Neon"
				part.Anchored = true
				part.CanCollide = false
				part.Shape = "Ball"
				part.Position = waypoint.Position
				part.Parent = workspace.World.PathFinding
				game.Debris:AddItem(part, 5)
				

				if (originialTargetPos - AIData.Target.Position).Magnitude > 10 or os.clock() - needsRepath > 1 then
					break
				end
				
				humanoid:MoveTo(waypoint.Position)
				humanoid.MoveToFinished:Wait()
			end
		end
		AIData.Moving = false
	end

end