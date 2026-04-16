local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local NPCService = require(ServerScriptService.Services.NPC.NPCService)
local SpawnService = require(ServerScriptService.Services.NPC.SpawnService)
local Arena = {}

function Arena:Init()
	local npc = nil
	local spawnLocation = workspace.World.Map.Coluseum.NPCSpawn
	local level = 0

	RunService.Heartbeat:Connect(function(dt)
		if not NPCService.SpawnedNPCS.Enemy[npc] then
			level += 1
			npc = SpawnService:SpawnNPC("Zombie", spawnLocation.Position, level)
		end
	end)
end

return Arena
