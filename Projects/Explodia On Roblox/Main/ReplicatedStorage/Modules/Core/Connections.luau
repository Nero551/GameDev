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
	
end

function Connections:CleanupConnections(char, type)
	if not Connections[char] then return end

	--* Cleanup Connections of a specific type
	if type then
		if Connections[char][type] then
			for _, conn in pairs(Connections[char][type]) do
				if conn and conn.Disconnect then
					conn:Disconnect()
				end
			end
			Connections[char][type] = nil
		end
	else
		--* Cleanup all connections
		for typeKey, typeTable in pairs(Connections[char]) do
			for _, conn in pairs(typeTable) do
				if conn and conn.Disconnect then
					conn:Disconnect()
				end
			end
			Connections[char][typeKey] = nil
		 end
	end 
end

return Connections
