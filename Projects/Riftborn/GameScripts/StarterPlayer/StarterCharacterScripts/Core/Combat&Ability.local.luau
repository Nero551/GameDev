-- Core Input Client
local replicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local remotes = replicatedStorage.Remotes
local player = game:GetService("Players").LocalPlayer
local modules =  replicatedStorage.Modules
local stateService = require(modules.StateService)
local character = script.Parent.Parent

local statusFolder = character:WaitForChild("Status", math.huge)
local humanoid:Humanoid = character:WaitForChild("Humanoid")

local actionVerifier = require(modules.ActionVerifier)


local proc = false
local stepConnection =  nil


local abilityKeys = {Z = "AbilityZ", X = "AbilityX", C = "AbilityC", V = "AbilityV", B = "AbilityB"}
UserInputService.InputBegan:Connect(function(input,processed)
	proc = processed
	if processed then return end
	
	---Abilties---
	if abilityKeys[input.KeyCode.Name] then		
		remotes.Ability:FireServer(player:GetMouse().Hit.Position, input.KeyCode.Name)
	end	
end)


stepConnection = runService.RenderStepped:Connect(function(deltaTime: number)
		
	------Death Handler------
	if statusFolder:FindFirstChild("Dead") then
		if stepConnection then
			stepConnection:Disconnect()
			stepConnection = nil
			return		
		end
	end
		
	--Renew BlockBreakCounter---
	if not stateService.checkState(character, "Blocking") then
		task.delay(5, function()
			if not stateService.checkState(character, "Blocking") then
				local blockCounter = statusFolder:WaitForChild("BlockCounter")
				blockCounter.Value = 0

			end
		end)
	end
	
	if proc then return end
		
	 ------M1------
	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and actionVerifier:CanAttack(character) then
		remotes.Attack:FireServer()
	end
	
	------Blocking------
	local wantBlock = UserInputService:IsKeyDown(Enum.KeyCode.F) and not proc
	
	if wantBlock ~= stateService.checkState(character, "Blocking") then
			remotes.Block:FireServer(wantBlock)	
	end
	local tool = character:FindFirstChildWhichIsA("Tool")
	if tool then
		if statusFolder:FindFirstChild("Blocking") then	
			if statusFolder:FindFirstChild("Blocking"):GetAttribute("weaponName") ~= tool.Name then
				remotes.Block:FireServer(false)
			end
		end
	end
end)