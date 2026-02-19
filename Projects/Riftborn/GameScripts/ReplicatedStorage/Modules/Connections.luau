local Connections = {}

function Connections:AddConnection(player, Type, connectionName, connection)
	if not Connections[player] then
		Connections[player] = {
			Character = {},
			Player = {}
		}
	end
	
	if not Connections[player][Type] then
		warn("Type Specified isnot a character nor player")
		return 
	end
	
	Connections:RemoveConnection(player, Type, connectionName)

	Connections[player][Type][connectionName] = connection
	
	print(Connections[player])
end

function Connections:RemoveConnection(player,Type, connectionName)
	
	if not Connections[player] then return end
	
	if not Connections[player][Type] then
		warn("Type Specified isnot a character nor player")
		return 
	end
	if Connections[player][Type][connectionName] then
		Connections[player][Type][connectionName]:Disconnect()
		Connections[player][Type][connectionName] = nil
	end
	
	print(Connections[player])
end

function Connections:CleanupConnections(player)
	if not Connections[player] then return end
	
	print(Connections[player])

	for typeKey, typeTable in pairs(Connections[player]) do
		for _, conn in pairs(typeTable) do
			if conn and conn.Disconnect then
				conn:Disconnect()
			end
		end
	end

	Connections[player] = nil
end

return Connections
