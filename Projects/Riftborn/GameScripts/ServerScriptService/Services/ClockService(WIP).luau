local lighting = game:GetService("Lighting")
local runService = game:GetService("RunService")
local serverData = require(script.Parent.Parent.Modules.ServerData)

local ClockService = {}

local DayLength = 24

local secondsPerDay = DayLength * 60

function ClockService:MoveTime(dt)
	serverData.Time = serverData.Time + dt
	if serverData.Time >= secondsPerDay then
		serverData.Time = 0
	end 
		
	local hour = serverData.Time / 60
	local minute = serverData.Time % 60
	
	local time = tostring(math.floor(hour)..":"..math.floor(minute))
	
	
	lighting.TimeOfDay = time
end


return ClockService
