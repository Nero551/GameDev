local tweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")


local DynamicLight = {}

function DynamicLight:Spawn(type, parent , color, brightness , range , duration:number?, fadeTime)
	local light = Instance.new(type)
	if not light then
		warn("Type Specified isn't a light type")
		return
	end
	
	light.Parent = parent
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Enabled = true
	
	if not fadeTime then
		fadeTime = 0.25
	end
	
	if duration then
		task.delay(duration,function()
			local info = TweenInfo.new(fadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			local tween = tweenService:Create(light,info,{Brightness = 0})
			tween:Play()
			tween.completed:Connect(function()
				light:Destroy()
			end)
		end)
	end
end


function DynamicLight:Destroy(light,duration:number?, fadeTime)
	if not fadeTime then
		fadeTime = 0.25
	end
	
	if duration then
		task.delay(duration,function()
			local info = TweenInfo.new(fadeTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			local tween = tweenService:Create(light,info,{Brightness = 0})
			tween:Play()
			tween.completed:Connect(function()
				light:Destroy()
			end)
		end)
	end
end

return DynamicLight
