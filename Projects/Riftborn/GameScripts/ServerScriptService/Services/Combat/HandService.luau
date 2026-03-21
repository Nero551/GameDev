local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local CharacterVitalsService = require(script.Parent.CharacterVitalsService)
local HandService = {}

function HandService:PutInHand(player:Player,toolId)
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid:Humanoid = char:WaitForChild("Humanoid")
    local toolData = ItemDataBase:GetItemData(toolId)
    if not char:FindFirstChild(toolData.Name) then
        CharacterVitalsService:ModifyVital(char, "InHand", "PutInHand",{
            ["ToolId"] = toolId
        })
        local tool = player.Backpack:FindFirstChild(toolData.Name)
        if tool then
            humanoid:EquipTool(tool)
        end
    end    
end

function HandService:RemoveFromHand(player:Player,toolId)
	local char = player.Character or player.CharacterAdded:Wait()
	local toolData = ItemDataBase:GetItemData(toolId)
    
	if CharacterVitalsService:GetVital(char, "InHand") == toolId then
		CharacterVitalsService:ModifyVital(char, "InHand", "RemoveFromHand", {
			["ToolId"] = toolId,
		})

		local tool = char:FindFirstChild(toolData.Name)
		if tool then
			tool.Parent = player.Backpack
		end    
	end
end

return HandService
