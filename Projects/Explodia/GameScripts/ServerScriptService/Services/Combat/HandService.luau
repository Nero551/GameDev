local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
local HandService = {}

function HandService:PutInHand(player:Player,toolId)
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid:Humanoid = char:WaitForChild("Humanoid")
    local toolData = ItemDataBase:GetItemData(toolId)
    if not char:FindFirstChild(toolData.Name) then
        VitalsService:ModifyVital(char, "InHand", "PutInHand",{
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
    
	if VitalsService:GetVital(char, "InHand") == toolId then
		VitalsService:ModifyVital(char, "InHand", "RemoveFromHand", {
			["ToolId"] = toolId,
		})

		local tool = char:FindFirstChild(toolData.Name)
		if tool then
			tool.Parent = player.Backpack
		end    
	end
end

return HandService
