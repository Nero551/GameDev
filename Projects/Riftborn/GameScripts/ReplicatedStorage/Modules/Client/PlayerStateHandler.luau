return function(character)
	local repstor = game:GetService("ReplicatedStorage")
	local runService = game:GetService("RunService")
	local starterGui = game:GetService("StarterGui")
	
	local humanoid:Humanoid = character:WaitForChild("Humanoid")

	local stateService = require(repstor.Modules.StateService)
	local StateHandler = require(repstor.Modules.StateHandler)
	
	local stepConnection
	stepConnection = runService.Heartbeat:Connect(function()

		------Death Handler------
		if stateService.checkState(character,"Dead") then
			if stepConnection then
				stepConnection:Disconnect()
				stepConnection = nil
				return		
			end
		end
		StateHandler:HandleStates(character)
	end)
end