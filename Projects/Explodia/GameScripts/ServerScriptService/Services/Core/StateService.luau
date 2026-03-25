local StateService = {}
StateService.Status = {}

function StateService:Create(character)
	if not StateService.Status[character] then
		StateService.Status[character] = {}
	end

	if not character:FindFirstChild("Status") then
		local statusFolder = Instance.new("Folder")
		statusFolder.Name = "Status"
		statusFolder.Parent = character
	end
end

function StateService:Destroy(character)
	if StateService.Status[character] then
		StateService.Status[character] = nil
	end
	if character:FindFirstChild("Status") then
		character:FindFirstChild("Status"):Destroy()
	end
end

function StateService:AddState(character, stateName, duration, attributes)
    print(stateName)
	if not character or not stateName then
		return
	end
	if not StateService.Status[character] then
		StateService:Create(character)
	end
	local charStatus = StateService.Status[character]
	local statusFolder = character:WaitForChild("Status")
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
	if StateService.Status[character] then
		StateService.Status[character][stateName] = nil
	else
		StateService:Create(character)
	end

	local statusFolder = character:FindFirstChild("Status")
	if statusFolder then
		local stateValue = statusFolder:FindFirstChild(stateName)
		if stateValue then
			stateValue:Destroy()
		end
	end
end

return StateService
