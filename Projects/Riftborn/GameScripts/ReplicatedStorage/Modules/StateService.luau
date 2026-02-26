--StateService
local runService = game:GetService("RunService")


local Service= {}

function Service.checkState(character, ...)
	if not character then return end
	local statusFolder = character:FindFirstChild("Status")
	if not statusFolder then return end
	
	local statusToCheck = {...}
	for _, stateName in pairs(statusToCheck) do
		if statusFolder:FindFirstChild(stateName) then
			return true
		end
	end
	return false
end
function Service.removeState(character ,stateName:string)
	local statusFolder = character:FindFirstChild("Status")
	if not statusFolder then return end
	for _, state in statusFolder:GetChildren() do
		if state.Name == stateName  then
			state:Destroy()
		end
	end
end
function Service.addState(character, stateName, duration, attributes)
	local statusFolder = character:FindFirstChild("Status")
	if not statusFolder then
		if runService:IsServer() then
			statusFolder = Instance.new("Folder")
			statusFolder.Name = "Status"
			statusFolder.Parent = character
		else
			return
		end
	
	end
	if character and stateName then
		if statusFolder:FindFirstChild(stateName) then
			return statusFolder[stateName]
		end
		
		
		local newState = Instance.new("BoolValue")
		newState.Name = stateName
		
		if attributes then
			for name,value  in attributes do
				newState:SetAttribute(name,value)
			end
		end
		
		newState.Parent = statusFolder
		
		if typeof(duration) == "number" and duration > 0  then
			task.delay(duration,function()
				newState:Destroy()
			end)
		end
		return newState
	end
	return nil
end



return Service