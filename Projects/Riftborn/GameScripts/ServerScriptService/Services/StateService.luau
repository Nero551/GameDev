local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Connections = require(ReplicatedStorage.Modules.Connections)
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

function StateService:AddState(character, stateName, duration, attributes)
    if not StateService.Status[character] then
        StateService:Create(character)
    end

    local charStatus = StateService.Status[character]
    charStatus[stateName] = {
        Duration = duration,
        Attributes = attributes
    }

    local statusFolder = character:FindFirstChild("Status")
    if statusFolder then
        local stateValue = Instance.new("StringValue")
        stateValue.Name = stateName
        stateValue.Parent = statusFolder
        for attr,Value in pairs(attributes) do
            stateValue:SetAttribute(attr, Value)
        end
        Connections:AddConnection(character, "Character", stateName, RunService.Heartbeat:Connect(function(dt)
            if charStatus[stateName] and charStatus[stateName].Duration then
                charStatus[stateName].Duration = charStatus[stateName].Duration - dt

                stateValue:SetAttribute("Duration", charStatus[stateName].Duration)

                for attr,Value in pairs(attributes) do
                     stateValue:SetAttribute(attr, Value)
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