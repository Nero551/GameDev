local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local Lighting = game:GetService("Lighting")
local ServerData = ModuleLoader:Load("Server", "ServerData")

local TimeService = {}

local DayLength = 24
local secondsPerDay = DayLength * 60

function TimeService:TimeCycle(dt)
	ServerData.Time = ServerData.Time + dt
	if ServerData.Time >= secondsPerDay then
		ServerData.Time = 0
	end 
	
	local hour = (ServerData.Time / 60)

	Lighting.ClockTime = hour
end

return TimeService
