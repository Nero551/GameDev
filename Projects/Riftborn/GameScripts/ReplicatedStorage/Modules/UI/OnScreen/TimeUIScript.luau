return function(timeText:TextLabel)
	local lighting = game:GetService("Lighting")
	
	timeText.Text = lighting.TimeOfDay
	
	
	lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
		
		local splits = lighting.TimeOfDay:split(":")
		local hour = tonumber(splits[1])
		local minute = tonumber(splits[2])
		
		
		local period = "AM"
		if hour > 12 then
			hour = hour - 12
			period = "PM"
		end
		
		if hour < 10 then
			hour = "0"..hour
		end
		
		if minute < 10 then
			minute = "0"..minute
		end
		
		local time = hour..":"..minute.." "..period
		timeText.Text = time
	end)
end