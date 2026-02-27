return function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local repstor = game:GetService("ReplicatedStorage")
	local runService = game:GetService("RunService")

	local assets = repstor.Assets
local StateChecker = require(ReplicatedStorage.Modules.StateChecker)
	local ActionVerifier =  require(repstor.Modules.ActionVerifier)
	local itemDataBase = require(repstor.Modules.Data.ItemDataBase)
	local animsModule = require(repstor.Modules.Animations)	
	
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()


	local function StopPreviousAnimation(current, Type)
		local previousTime = 0
		for animName,anim in pairs(animsModule.loadedAnimations[char]) do
			if string.find(animName, "Animations."..Type)  then
				if anim ~= current and anim.IsPlaying then
					previousTime = anim.TimePosition
					anim:Stop(0.2)
				end	
			end
		end
		return previousTime
	end

	---MainStateAnimations---
	local humanoid = char:WaitForChild("Humanoid")
	local animator = humanoid.Animator

	animsModule:loadAnims(animator, assets.Shared)

	local currentIdle:AnimationTrack
	local currentRun:AnimationTrack
	local currentWalk:AnimationTrack
	local conn:RBXScriptConnection

	if not animsModule.loadedAnimations[char]["Shared.Animations.Idle.Default"].IsPlaying then
		animsModule:GetAnimation(humanoid.Animator, "Shared.Animations.Idle.Default"):Play()
	end


	conn = runService.RenderStepped:Connect(function(dt)

		if StateChecker:CheckState(char, "Dead") then
			if not conn then return end
			conn:Disconnect()
		end

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

		end

		---Falling Animation---
		if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
			animsModule:GetAnimation(humanoid.Animator, "Shared.Animations.Fall.Fall"):Play()
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
		if  humanoid.MoveDirection.Magnitude <=  0 or char:GetAttribute("WalkSpeed") == 0 then
			local previousTime = StopPreviousAnimation(currentIdle, "Idle")

			if not currentIdle.IsPlaying  then					
				currentIdle:Play()
				currentIdle.TimePosition = previousTime

				currentWalk:Stop(0.2)
				currentRun:Stop(0.2)
			end
			return

			---Sprint---
		elseif	StateChecker:CheckState(char,"Sprinting") and ActionVerifier:CanSprint(char) then				
			local previousTime = StopPreviousAnimation(currentRun, "Run")

			if not currentRun.IsPlaying then
				currentRun:Play()
				currentRun.TimePosition = previousTime

				currentWalk:Stop(0.2)
				currentIdle:Stop(0.2)
			end
			return


			---Walk---
		elseif	ActionVerifier:CanWalk(char) then	
			local previousTime = StopPreviousAnimation(currentWalk, "Walk")

			if not currentWalk.IsPlaying then
				currentWalk:Play()
				currentWalk.TimePosition = previousTime


				currentRun:Stop(0.2)
				currentIdle:Stop(0.2)
			end
			return
		end

		currentRun:Stop(0.2)
		currentIdle:Stop(0.2)
	end)	


end