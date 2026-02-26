return function()
		
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")
	local runService = game:GetService("RunService")
	local remotes = replicatedStorage.Remotes
	local player = game:GetService("Players").LocalPlayer
	local modules =  replicatedStorage.Modules
	local stateService = require(modules.StateService)
	local character = player.Character or player.CharacterAdded:Wait()

	local statusFolder = character:WaitForChild("Status", math.huge)

	local actionVerifier = require(modules.ActionVerifier)


	-- blocking is handled on input events instead of a stale `proc` flag

	local abilityKeys = {Z = "AbilityZ", X = "AbilityX", C = "AbilityC", V = "AbilityV", B = "AbilityB"}


	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end

		---Abilities---
		if abilityKeys[input.KeyCode.Name] then
			remotes.Ability:FireServer(player:GetMouse().Hit.Position, input.KeyCode.Name)
		end

		-- Start blocking when F is pressed
		if input.KeyCode == Enum.KeyCode.F then
			remotes.Block:FireServer(true)
		end
	end)

	-- Stop blocking when F is released
	UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.F then
			remotes.Block:FireServer(false)
		end
	end)
	
	local stepConnection =  nil

	stepConnection = runService.RenderStepped:Connect(function(deltaTime: number)

		------Death Handler------
		if stateService.checkState(character, "Dead") then
			if stepConnection then
				stepConnection:Disconnect()
				stepConnection = nil
				return		
			end
		end

		------M1------
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and actionVerifier:CanAttack(character) then
			remotes.Attack:FireServer()
		end

		local tool = character:FindFirstChildWhichIsA("Tool")

		if tool then
			if statusFolder:FindFirstChild("Blocking") then	
				if statusFolder:FindFirstChild("Blocking"):GetAttribute("weaponName") ~= tool.Name then
					remotes.Block:FireServer(false)
				end
			end

		else
			if statusFolder:FindFirstChild("Blocking") then
				remotes.Block:FireServer(false)
			end
		end
	end)
end