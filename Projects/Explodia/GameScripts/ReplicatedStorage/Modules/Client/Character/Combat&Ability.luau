return function()
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local Player = game:GetService("Players").LocalPlayer
	local ActionVerifier = require(game.ReplicatedStorage.Modules.Helpers.ActionVerifier)
	local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)
	local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
	local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
	local character = Player.Character or Player.CharacterAdded:Wait()

	local stateFolder = character:WaitForChild("State", math.huge)

	local proc = false

	UserInputService.InputBegan:Connect(function(input, processed)
		proc = processed
	end)

	Connections:AddConnection(
		character,
		"Character",
		"Block & Attack",
		RunService.RenderStepped:Connect(function(deltaTime: number)
			------Death Handler------
			if StateChecker:CheckState(character, "Dead") then
				Connections:RemoveConnection(character, "Character", "Block & Attack")
				return
			end

			if proc then
				return
			end
			local tool = character:FindFirstChildWhichIsA("Tool")
			------M1------
			if
				UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
				and not StateChecker:CheckState(character, "Attacking")
				and ActionVerifier:CanAttack(character)
				and tool
			then
				NetworkingService:FireToServer("Attack")
			end
			------Blocking------
			if UserInputService:IsKeyDown(Enum.KeyCode.F) and ActionVerifier:CanBlock(character) and tool then
				if
					StateChecker:CheckState(character, "Blocking")
					and stateFolder:FindFirstChild("Blocking"):GetAttribute("weaponName") ~= tool.Name
				then
					NetworkingService:FireToServer("Block", 0)
				elseif not StateChecker:CheckState(character, "Blocking") and ActionVerifier:CanBlock(character) then
					NetworkingService:FireToServer("Block", 1)
				end
			elseif StateChecker:CheckState(character, "Blocking") then
				NetworkingService:FireToServer("Block", 0)
			end
		end)
	)
end
