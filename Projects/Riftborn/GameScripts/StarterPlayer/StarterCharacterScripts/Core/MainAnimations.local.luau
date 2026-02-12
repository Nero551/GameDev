local repstor = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local itemDataBase = require(repstor.Modules.Data.ItemDataBase)


local character = script.Parent.Parent
local statusFolder = character:WaitForChild("Status")
local humanoid:Humanoid = character:WaitForChild("Humanoid")
local animsModule = require(script.Parent.Animations)

currentWalk = Instance.new("StringValue")
currentWalk.Name = "currentWalk"
currentWalk.Value = ""
currentWalk.Parent = statusFolder

currentIdle = Instance.new("StringValue")
currentIdle.Name = "CurrentIdle"
currentIdle.Value = ""
currentIdle.Parent = statusFolder

currentRun = Instance.new("StringValue")
currentRun.Name = "CurrentRun"
currentRun.Value = ""
currentRun.Parent = statusFolder

------ChangeRun------
local function changeRun()
	local foundTool = character:FindFirstChildWhichIsA("Tool")
	if foundTool then
		if itemDataBase:GetItemData(foundTool:GetAttribute("ID")) then
			local previous = currentRun.Value
			currentRun.Value = "Client.Run."..foundTool.Name
			return {previousRun = previous}
		end
	end
	if currentRun.Value ~= "Client.Run.Default" then
		local previous = currentRun.Value
		currentRun.Value = "Client.Run.Default"
		return {previousRun = previous}
	end

	currentRun.Value = "Client.Run.Default"
	return {}

end


------ChangeWalk------
local function changeWalk()
	local foundTool = character:FindFirstChildWhichIsA("Tool")
	if foundTool then
		if itemDataBase:GetItemData(foundTool:GetAttribute("ID")) then
			local previous = currentWalk.Value
			currentWalk.Value = "Client.Walk."..foundTool.Name
			return {previousWalk = previous}
		end
	end
	if currentWalk.Value ~= "Client.Walk.Default" then
		local previous = currentWalk.Value
		currentWalk.Value = "Client.Walk.Default"
		return {previousWalk = previous}
	end

	currentWalk.Value = "Client.Walk.Default"
	return {}

end

------ChangeIdle------
local function changeIdle()
	local foundTool = character:FindFirstChildWhichIsA("Tool")
	if foundTool then
		if itemDataBase:GetItemData(foundTool:GetAttribute("ID")) then
			local previous = currentIdle.Value
			currentIdle.Value = "Client.Idle."..foundTool.Name
			return {previousIdle = previous}
		end

	end
	if not foundTool then
		if currentIdle.Value ~= "Client.Idle.Default" then
			local previous = currentIdle.Value
			currentIdle.Value = "Client.Idle.Default"
			return {previousIdle = previous}
		end

		currentIdle.Value = "Client.Idle.Default"
	end
	
	return {}

end

local function isMoving()
	return  (humanoid.MoveDirection.Magnitude >  0)
end

stepConnection =  runService.RenderStepped:Connect(function()
	------Death Handler------
	if statusFolder:FindFirstChild("Dead") then
		if stepConnection then
			stepConnection:Disconnect()
			stepConnection = nil
			return		
		end
	end
	
	---Jump Animation---
	if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
 		animsModule.loadedAnimations["Client.Jump.Jump"]:Play()
	else
		animsModule.loadedAnimations["Client.Jump.Jump"]:Stop()
	end
	
	---Falling Animation---
	if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		animsModule.loadedAnimations["Client.Fall.Fall"]:Play()
	else
		animsModule.loadedAnimations["Client.Fall.Fall"]:Stop()
	end
	
	---Landing Animation---
	if humanoid:GetState() == Enum.HumanoidStateType.Landed then
		---Landing Animation
	end
	
	
	------Idle & Running & Walking Animations------
	if humanoid:GetState() == Enum.HumanoidStateType.Jumping or  humanoid:GetState() == Enum.HumanoidStateType.Freefall or 
		humanoid:GetState() == Enum.HumanoidStateType.Landed then

		for name, anim in animsModule.loadedAnimations do
			if string.find(name, "Client.Run") or string.find(name , "Client.Idle") or string.find(name, "Client.Walk") then
				if anim.IsPlaying then
					anim:Stop(0.2)
				end
			end
		end
		return
	end

	---Idle Section---
	if  isMoving() then 
		local foundNewIdle = animsModule.loadedAnimations[currentIdle.Value]
		if foundNewIdle then
			if  foundNewIdle.IsPlaying  then
				foundNewIdle:Stop(0.2)
			end
		end	
	else

		local returnedTable = changeIdle()
		if returnedTable.previousIdle ~= currentIdle.Value then
			local foundPrevious = animsModule.loadedAnimations[returnedTable.previousIdle]
			if foundPrevious and foundPrevious.IsPlaying then

				foundPrevious:Stop(0.2)
			end
		end
		local foundNewIdle = animsModule.loadedAnimations[currentIdle.Value]
		if foundNewIdle and not foundNewIdle.IsPlaying then
			foundNewIdle:Play()
		end	
	end

	---Walk Section---
	if isMoving() and not (statusFolder:FindFirstChild("Attacking") or statusFolder:FindFirstChild("Blocking") 
		or statusFolder:FindFirstChild("NoMove") or statusFolder:FindFirstChild("Stunned") 
		or statusFolder:FindFirstChild("NoSprint") or statusFolder:FindFirstChild("Sprinting")) then

		local returnedTable = changeWalk()
		if returnedTable.previousWalk ~= currentWalk.Value then
			local foundPrevious = animsModule.loadedAnimations[returnedTable.previousWalk]
			if foundPrevious and foundPrevious.IsPlaying then
				foundPrevious:Stop(0.2)
			end
		end
		local foundWalk = animsModule.loadedAnimations[currentWalk.Value]
		if foundWalk and not foundWalk.IsPlaying then
			foundWalk:Play()
		end	
	else
		local foundWalk = animsModule.loadedAnimations[currentWalk.Value]
		if foundWalk and foundWalk.IsPlaying then
			foundWalk:Stop(0.2)
		end	

	end

	---Sprint Section---
	if isMoving() and statusFolder:FindFirstChild("Sprinting") then
		if statusFolder:FindFirstChild("Attacking") or statusFolder:FindFirstChild("Blocking") then
			for name, anim in animsModule.loadedAnimations do
				if string.find(name, "Client.Run") or string.find(name , "Client.Idle") then
					if anim.IsPlaying then
						anim:Stop(0.2)
					end
				end
			end
			return 
		end
		local returnedTable = changeRun()
		if returnedTable.previousRun ~= currentRun.Value then
			local foundPrevious = animsModule.loadedAnimations[returnedTable.previousRun]
			if foundPrevious and foundPrevious.IsPlaying then
				foundPrevious:Stop(0.2)
			end
		end

		local foundNewRun = animsModule.loadedAnimations[currentRun.Value]
		if foundNewRun and not foundNewRun.IsPlaying then
			foundNewRun:Play()

		end	

	else
		local foundNewRun = animsModule.loadedAnimations[currentRun.Value]
		if foundNewRun then
			if  foundNewRun.IsPlaying  then
				foundNewRun:Stop(0.2)
			end
		end		
	end
end)
