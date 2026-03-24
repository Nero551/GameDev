return function()
		
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local Player = game:GetService("Players").LocalPlayer
	local ActionVerifier = require(game.ReplicatedStorage.Modules.Helpers.ActionVerifier)
	local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)
	local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
	local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
	local character = Player.Character or Player.CharacterAdded:Wait()

	local statusFolder = character:WaitForChild("Status", math.huge)

	local proc = false

	local abilityKeys = {Z = "AbilityZ", X = "AbilityX", C = "AbilityC", V = "AbilityV", B = "AbilityB"}


	UserInputService.InputBegan:Connect(function(input,processed)
		proc = processed
		if processed then return end

		---Abilties---
		if abilityKeys[input.KeyCode.Name] then				
			NetworkingService:FireToServer("Ability", Player:GetMouse().Hit.Position, input.KeyCode.Name)
		end	
	end)

	Connections:AddConnection(character, "Character", "Block & Attack",RunService.RenderStepped:Connect(function(deltaTime: number)
		------Death Handler------
		if StateChecker:CheckState(character, "Dead") then
			Connections:RemoveConnection(character, "Character", "Block & Attack")
			return
		end

		if proc then return end
		------M1------
		if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) 
		and not StateChecker:CheckState(character, "Attacking") and ActionVerifier:CanAttack(character)  then
			NetworkingService:FireToServer("Attack")
		end
		------Blocking------
		if UserInputService:IsKeyDown(Enum.KeyCode.F) and ActionVerifier:CanBlock(character) then
			local tool = character:FindFirstChildWhichIsA("Tool")

			if tool and StateChecker:CheckState(character, "Blocking")
				and statusFolder:FindFirstChild("Blocking"):GetAttribute("weaponName") ~= tool.Name then
				NetworkingService:FireToServer("Block", false)

			elseif not StateChecker:CheckState(character, "Blocking") then
				NetworkingService:FireToServer("Block", true)
			end

		elseif StateChecker:CheckState(character, "Blocking") then
			NetworkingService:FireToServer("Block", false)	
		end
	end))
end
