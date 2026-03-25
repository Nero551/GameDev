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
				["Health"] = math.round(
					(math.random(mobData.MinHealth, mobData.MaxHealth) or mobData.Health) * ((level or 1) / 3.5)
				),
				["MinDamage"] = math.round(mobData.MinDamage * ((level or 1) / 3.5)),
				["MaxDamage"] = math.round(mobData.MaxDamage * ((level or 1) / 3.5)),
				["Drops"] = mobData.Drops,
			}

			for drop, amount in pairs(NPCService.SpawnedNPCS[npcType][NPC].Drops) do
				if typeof(amount) ~= "table" then
					NPCService.SpawnedNPCS[npcType][NPC].Drops[drop] = math.round(amount * ((level or 1) / 3.5))
				end
			end

			NPC:SetAttribute("Type", npcType)
			NPC:SetAttribute("Active", true)
			NPC:SetAttribute("Level", NPCService.SpawnedNPCS[npcType][NPC].Level)
			NPC:SetAttribute("MinDamage", NPCService.SpawnedNPCS[npcType][NPC].MinDamage)
			NPC:SetAttribute("MaxDamage", NPCService.SpawnedNPCS[npcType][NPC].MaxDamage)
			VitalsService:Create(NPC)
			VitalsService:ModifyVital(NPC, "Health", "ModifyMaxHealth", {
				["MaxHealth"] = NPCService.SpawnedNPCS[npcType][NPC].Health,
			})
			VitalsService:ModifyVital(NPC, "Health", "ModifyHealth", {
				["HealthChange"] = NPCService.SpawnedNPCS[npcType][NPC].Health,
			})
			require(script[npcType .. "NPC"])(NPC)

			NPC.Humanoid.Died:Connect(function()
				NPCService:UnRegisterNPC(NPC)
			end)
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
