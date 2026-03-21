return function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")

	local assets = ReplicatedStorage.Assets
local StateChecker = require(ReplicatedStorage.Modules.Helpers.StateChecker)
	local ActionVerifier =  require(ReplicatedStorage.Modules.Helpers.ActionVerifier)
	local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
	local Animations = require(ReplicatedStorage.Modules.Core.Animations)	
	
	local Player = game:GetService("Players").LocalPlayer
	local char = Player.Character or Player.CharacterAdded:Wait()


	local function StopPreviousAnimation(current, Type)
		local previousTime = 0
		for animName,anim in pairs(Animations.loadedAnimations[char]) do
			if string.find(animName, Type)  then
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

	Animations:loadAnims(animator, assets.Shared)

	local currentIdle:AnimationTrack
	local currentRun:AnimationTrack
	local currentWalk:AnimationTrack
	local conn:RBXScriptConnection

	if not Animations.loadedAnimations[char]["Shared.Animations.Idle.Default"].IsPlaying then
		Animations:GetAnimation(humanoid.Animator, "Shared.Animations.Idle.Default"):Play()
	end


	conn = RunService.RenderStepped:Connect(function(dt)

		if StateChecker:CheckState(char, "Dead") then
			if not conn then return end
			conn:Disconnect()
		end

		local tool = char:FindFirstChildWhichIsA("Tool")

		if tool then
			local weaponData = ItemDataBase:GetItemData(tool:GetAttribute("ID"))
			if weaponData then

				currentIdle = Animations:GetAnimation(animator, "Weapons."..tool.Name..".Animations.Idle")
				currentRun = Animations:GetAnimation(animator, "Weapons."..tool.Name..".Animations.Run")
				currentWalk = Animations:GetAnimation(animator, "Weapons."..tool.Name..".Animations.Walk")
			end

		else

			currentIdle = Animations:GetAnimation(animator, "Shared.Animations.Idle.Default")
			currentRun = Animations:GetAnimation(animator, "Shared.Animations.Run.Default")
			currentWalk = Animations:GetAnimation(animator, "Shared.Animations.Walk.Default")
		end


		---Jump Animation---
		if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
			Animations:GetAnimation(humanoid.Animator, "Shared.Animations.Jump.Jump"):Play()

		end

		---Falling Animation---
		if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
			Animations:GetAnimation(humanoid.Animator, "Shared.Animations.Fall.Fall"):Play()
		end

		---Landing Animation---
		if humanoid:GetState() == Enum.HumanoidStateType.Landed then
		end


		if humanoid:GetState() == Enum.HumanoidStateType.Jumping or  humanoid:GetState() == Enum.HumanoidStateType.Freefall or 
			humanoid:GetState() == Enum.HumanoidStateType.Landed then

			for name, anim in Animations.loadedAnimations[char] do
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
