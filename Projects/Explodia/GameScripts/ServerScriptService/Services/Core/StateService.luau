local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)
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
	if not character or not stateName then return end
    if not StateService.Status[character] then
        StateService:Create(character)
    end

    local charStatus = StateService.Status[character]
    local statusFolder = character:WaitForChild("Status")
	local stateValue = statusFolder:FindFirstChild(stateName)

    if charStatus[stateName] then
        if duration then
            charStatus[stateName].Duration = duration
            stateValue:SetAttribute("Duration", duration)   
            if duration <= 0 then
                StateService:RemoveState(character, stateName)
            end     
        end
        if attributes and stateName and charStatus[stateName] then
            for attrName,Value in pairs(attributes) do
                charStatus[stateName][attrName] = Value
                stateValue:SetAttribute(attrName, Value)
            end
        end
        return
    end

    charStatus[stateName] = {
        Duration =  duration,
    }
    
	if not stateValue then
		stateValue = Instance.new("StringValue")
		stateValue.Name = stateName
		stateValue.Parent = statusFolder
	end 
	if duration then
		stateValue:SetAttribute("Duration", duration)
	end 
	if attributes then
		for attrName,Value in pairs(attributes) do
            charStatus[stateName][attrName] = Value
            stateValue:SetAttribute(attrName, Value)
		end
	end

	if charStatus[stateName].Duration then
		Connections:AddConnection(character, "Character", stateName, RunService.Heartbeat:Connect(function(dt)
			if charStatus[stateName] and charStatus[stateName].Duration then
				charStatus[stateName].Duration = charStatus[stateName].Duration - dt

				stateValue:SetAttribute("Duration", charStatus[stateName].Duration)

				if attributes then
					for attrName,Value in pairs(attributes) do
						stateValue:SetAttribute(attrName, Value)
					end
				end

				if charStatus[stateName].Duration <= 0 then
					Connections:RemoveConnection(character, "Character", stateName)
					StateService:RemoveState(character, stateName)
				end
			end
		end))
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
