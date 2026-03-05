local lighting = game:GetService("Lighting")
local serverData = require(script.Parent.Parent.Modules.ServerData)

local TimeService = {}

local DayLength = 24
local secondsPerDay = DayLength * 60

function TimeService:TimeCycle(dt)
	serverData.Time = serverData.Time + dt
	if serverData.Time >= secondsPerDay then
		serverData.Time = 0
	end 
	
	local hour = (serverData.Time / 60)

	lighting.ClockTime = hour
end

return TimeService