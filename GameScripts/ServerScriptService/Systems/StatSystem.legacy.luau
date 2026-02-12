local players = game:GetService("Players")
local repstor = game:GetService("ReplicatedStorage")
local remotes = repstor.Remotes
local StatService = require(script.Parent.Parent.ServerModules.StatService)
local ManaService = require(script.Parent.Parent.ServerModules.ManaService)





---Client Requests To Allocate Stat Point---
remotes.AllocateStatPoint.OnServerEvent:Connect(function(player:Player, StatType, amount)
	
	StatService:AllocateStatPoint(player, StatType, amount)
end)

---Client Requests To Reset Stat Points---
remotes.ResetStatPoints.OnServerEvent:Connect(function(player)	
	StatService:ResetStats(player)
end)


