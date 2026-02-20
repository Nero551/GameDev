local Connections = {}

function Connections:AddConnection(char, Type, connectionName, connection)
	if not Connections[char] then
		Connections[char] = {
			Character = {},
			Player = {}
		}
	end
	
	if not Connections[char][Type] then
		warn("Type Specified isnot a character nor player")
		return 
	end
	
	Connections:RemoveConnection(char, Type, connectionName)

	Connections[char][Type][connectionName] = connection
	
	print(Connections[char])
end

function Connections:RemoveConnection(char,Type, connectionName)
	
	if not Connections[char] then return end
	
	if not Connections[char][Type] then
		warn("Type Specified isnot a character nor player")
		return 
	end
	if Connections[char][Type][connectionName] then
		Connections[char][Type][connectionName]:Disconnect()
		Connections[char][Type][connectionName] = nil
	end
	
	print(Connections[char])
end

function Connections:CleanupConnections(char)
	if not Connections[char] then return end
	
	print(Connections[char])

	for typeKey, typeTable in pairs(Connections[char]) do
		for _, conn in pairs(typeTable) do
			if conn and conn.Disconnect then
				conn:Disconnect()
			end
		end
	end

	Connections[char] = nil
end

return Connections
