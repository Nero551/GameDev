local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CombatService = require(ServerScriptService.Services.Combat.CombatService)
local NPCService = require(ServerScriptService.Services.NPC.NPCService)
local MobData = require(ReplicatedStorage.Modules.Data.MobData)
local SpawnService = {}

function SpawnService:SpawnNPC(npcName, location, level)
	local mobData = MobData.Mobs[npcName]
	if mobData then
		local model = ReplicatedStorage.Assets.NPCS:FindFirstChild(mobData.Type)
			and ReplicatedStorage.Assets.NPCS:FindFirstChild(mobData.Type):FindFirstChild(npcName)
		if model then
			local clone = model:Clone()
			if typeof(location) == "Vector3" then
				clone.HumanoidRootPart.Position = location
			end
			clone.Parent = workspace.World.Live.ActiveNPCS[mobData.Type]
			CombatService:Spawn(clone)
			NPCService:RegisterNPC(clone, level)
			return clone
		end
	end
	return
end

return SpawnService
