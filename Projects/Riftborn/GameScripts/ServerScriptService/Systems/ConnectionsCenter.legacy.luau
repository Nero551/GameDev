local connections = require(game.ReplicatedStorage.Modules.Connections)

local players = game:GetService("Players")

players.PlayerRemoving:Connect(function(player)
	connections:CleanupConnections(player)
end)	