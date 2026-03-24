local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local VitalsService = require(ServerScriptService.Services.Combat.VitalsService)
local MobData = require(ReplicatedStorage.Modules.Data.MobData)

local NPCService = {}

NPCService.SpawnedNPCS = {
	Boss = {},
	Enemy = {},
	Quest = {},
	Neutral = {},
	Ally = {},
}

function NPCService:RegisterNPC(NPC, level)
	if NPC:IsA("Model") then
		local mobData = MobData.Mobs[NPC.Name]
		if mobData then
			local npcType = mobData.Type
			if NPCService.SpawnedNPCS[npcType][NPC] then
				return
			end

			NPCService.SpawnedNPCS[npcType][NPC] = {
				["Name"] = mobData.Name,
				["Active"] = true,
				["Type"] = npcType,
				["Level"] = level or 1,
				["Health"] = (math.random(mobData.MinHealth, mobData.MaxHealth) or mobData.Health) * ((level or 1) / 3.5),
				["MinDamage"] = mobData.MinDamage * ((level or 1) / 3.5) ,
				["MaxDamage"] = mobData.MaxDamage * ((level or 1) / 3.5) ,
			}
			NPC:SetAttribute("Type", npcType)
			NPC:SetAttribute("Active", true)
			NPC:SetAttribute("Level", NPCService.SpawnedNPCS[npcType][NPC].Level)
			NPC:SetAttribute("MinDamage",NPCService.SpawnedNPCS[npcType][NPC].MinDamage)
			NPC:SetAttribute("MaxDamage", NPCService.SpawnedNPCS[npcType][NPC].MaxDamage)
			VitalsService:Create(NPC)
			VitalsService:ModifyVital(NPC, "Health", "ModifyMaxHealth", {
				["MaxHealth"] = NPCService.SpawnedNPCS[npcType][NPC].Health,
			})
			VitalsService:ModifyVital(NPC, "Health", "ModifyHealth", {
				["HealthChange"] = NPCService.SpawnedNPCS[npcType][NPC].Health,
			})
			require(script[npcType .. "NPC"])(NPC)
		end
	end
end

function NPCService:UnRegisterNPC(NPC)
	if NPC:IsA("Model") then
		local npcType = MobData.Mobs[NPC.Name].Type
		if not NPCService.SpawnedNPCS[npcType][NPC] then
			return
		end
		NPCService.SpawnedNPCS[npcType][NPC] = nil
	end
end

return NPCService
