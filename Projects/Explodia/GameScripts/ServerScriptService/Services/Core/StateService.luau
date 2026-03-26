local StateService = {}
StateService.State = {}
StateService.Status = StateService.State

function StateService:Create(character)
	if not StateService.State[character] then
		StateService.State[character] = {}
	end

	if not character:FindFirstChild("State") then
		local statusFolder = Instance.new("Folder")
		statusFolder.Name = "State"
		statusFolder.Parent = character
	end
end

function StateService:Destroy(character)
	if StateService.State[character] then
		StateService.State[character] = nil
	end
	if character:FindFirstChild("State") then
		character:FindFirstChild("State"):Destroy()
	end
end

function StateService:AddState(character, stateName, duration, attributes)
	if not character or not stateName then
		return
	end
	if not StateService.State[character] then
		StateService:Create(character)
	end
	local charStatus = StateService.State[character]
	local statusFolder = character:WaitForChild("State")
	local stateValue = statusFolder:FindFirstChild(stateName)

	charStatus[stateName] = {
		Duration = duration,
	}

	if not stateValue then
		stateValue = Instance.new("StringValue")
		stateValue.Name = stateName
		stateValue.Parent = statusFolder
	end
	stateValue:SetAttribute("Duration", duration)
	if attributes then
		for attrName, Value in pairs(attributes) do
			charStatus[stateName][attrName] = Value
			stateValue:SetAttribute(attrName, Value)
		end
	end
end

function StateService:RemoveState(character, stateName)
	if StateService.State[character] then
		StateService.State[character][stateName] = nil
	else
		StateService:Create(character)
	end

	local stateFolder = character:FindFirstChild("State")
	if stateFolder then
		local stateValue = stateFolder:FindFirstChild(stateName)
		if stateValue then
			stateValue:Destroy()
		end
	end
end

return StateService
