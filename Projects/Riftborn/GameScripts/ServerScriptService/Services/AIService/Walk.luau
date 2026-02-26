return function(npc)
	local PathFindingService = game:GetService("PathfindingService")
	
	local AIService = require(script.Parent)
	local AIData = AIService.ActiveAIs[npc]
	local CharacterVitalsService = require(script.Parent.Parent.Parent.Services.CharacterVitalsService)
	if not AIData then return end
	local humanoid:Humanoid = npc:WaitForChild("Humanoid")

	AIService:AcquireTarget(npc)
	if not AIData.Target then return end

	CharacterVitalsService:ModifyVital(npc, "Movement", "ModifyWalkSpeed", {
		["WalkSpeed"] = AIData.WalkSpeed	
	})
	if not AIData.WalkAnimation.IsPlaying then
		AIData.WalkAnimation:Play()
	end
	
	local path = PathFindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = false,
	})

	local needsRepath
	needsRepath = needsRepath or os.clock()

	if not AIData.Moving  then
		AIData.Moving = true

		path:ComputeAsync(AIData.Root.Position, AIData.Target.Position)

		if path.Status ~= Enum.PathStatus.Success then
			AIData.Moving = false
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

				local part = Instance.new("Part")
				part.Material = "Neon"
				part.Anchored = true
				part.CanCollide = false
				part.Shape = "Ball"
				part.Position = waypoint.Position
				part.Parent = workspace.World.PathFinding
				game.Debris:AddItem(part, 5)


				if (originalTargetPos - AIData.Target.Position).Magnitude > 10 or os.clock() - needsRepath > 1 then
					break
				end

				humanoid:MoveTo(waypoint.Position)
				local reached = humanoid.MoveToFinished:Wait()
				if not reached then
					break
				end
			end
		end
		needsRepath = 0
		AIData.Moving = false
	end
end