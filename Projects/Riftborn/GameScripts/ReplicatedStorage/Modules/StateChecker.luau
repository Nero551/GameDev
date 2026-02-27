local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local StateService = require(ServerScriptService.Services.StateService)
--StateService


local Service = {}

function Service:checkState(character, ...)
	if not character then return end
	
	local statusToCheck = {...}

	if RunService:IsServer() then
		if not StateService.Status[character] then return end
		
		for _, stateName in pairs(statusToCheck) do
			if StateService.Status[character][stateName] then
				return true
			end
		end

	elseif RunService:IsClient() then
		local statusFolder = character:FindFirstChild("Status")
		if not statusFolder then return end
		
		for _, stateName in pairs(statusToCheck) do
			if statusFolder:FindFirstChild(stateName) then
				return true
			end
		end
	end

	return false
end


return Service