local RunService = game:GetService("RunService")

local StateChecker = {}

function StateChecker:CheckState(character, ...)
	if not character then
		return
	end

	local statusToCheck = { ... }

	if RunService:IsServer() then
		local StateService = require(game.ServerScriptService.Services.Core.StateService)
		if not StateService.State[character] then
			return
		end

		for _, stateName in pairs(statusToCheck) do
			if StateService.State[character][stateName] then
				return true
			end
		end
	elseif RunService:IsClient() then
		local stateFolder = character:FindFirstChild("State")
		if not stateFolder then
			return
		end

		for _, stateName in pairs(statusToCheck) do
			if stateFolder:FindFirstChild(stateName) then
				return true
			end
		end
	end

	return false
end

return StateChecker
