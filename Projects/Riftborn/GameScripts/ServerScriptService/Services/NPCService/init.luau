local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MobData = require(ReplicatedStorage.Modules.Data.MobData)



local NPCService = {}

NPCService.SpawnedNPCS = {
	Boss = {},
	Enemy = {},
    Quest = {},
    Neutral = {},
    Ally = {},
}

function NPCService:RegisterNPC(NPC)
    if NPC:IsA("Model") then
        local npcType = MobData.Mobs[NPC.Name].Type
        if NPCService.SpawnedNPCS[npcType][NPC] then return end
		NPC:SetAttribute("Type", npcType)
		NPCService.SpawnedNPCS[npcType][NPC] = {
            ["Type"] = npcType
        }
		require(script[npcType.."NPC"])(NPC)
	end
end

function NPCService:UnRegisterNPC(NPC)
    if NPC:IsA("Model") then
        local npcType = MobData.Mobs[NPC.Name].Type
        if not NPCService.SpawnedNPCS[npcType][NPC] then return end
		NPCService.SpawnedNPCS[npcType][NPC] = nil
	end
end
return NPCService
