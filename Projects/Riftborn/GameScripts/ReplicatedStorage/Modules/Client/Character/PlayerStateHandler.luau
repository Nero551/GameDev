return function()
	local repstor = game:GetService("ReplicatedStorage")
	local runService = game:GetService("RunService")
	local starterGui = game:GetService("StarterGui")
	local player = game:GetService("Players").LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid:Humanoid = character:WaitForChild("Humanoid")

	local stateService = require(repstor.Modules.StateService)
	local StateHandler = require(repstor.Modules.StateHandler)


	stepConnection = runService.RenderStepped:Connect(function()

		------Death Handler------
		if stateService.checkState(character,"Dead") then
			if stepConnection then
				stepConnection:Disconnect()
				stepConnection = nil
				return		
			end
		end

		---In Combat---
		local inCombat = stateService.checkState(character, "In Combat")
		pcall(function()
			if inCombat then
				starterGui:SetCore("ResetButtonCallback", false)
				player.PlayerGui.OnScreenGUI.InCombatText.Visible = true
			else
				starterGui:SetCore("ResetButtonCallback", true)
				player.PlayerGui.OnScreenGUI.InCombatText.Visible = false
			end
		end)

		StateHandler:HandleStates(character)
	end)

end