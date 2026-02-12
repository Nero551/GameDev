local repstor = game:GetService("ReplicatedStorage")
local StateService = require(repstor.Modules.StateService)

-- Gradually regenerates the Humanoid's Health over time.

local REGEN_RATE = 1/100 -- Regenerate this fraction of MaxHealth per second.
local REGEN_STEP = 1 -- Wait this long between each regeneration step.

--------------------------------------------------------------------------------

local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")

--------------------------------------------------------------------------------

while true do
	while Humanoid.Health < Humanoid.MaxHealth do
		if StateService.checkState(Character, "In Combat") then
			REGEN_RATE = 1/500
		else
			task.delay(3, function()
				REGEN_RATE = 1/100
			end)
		end
		
		local dt = wait(REGEN_STEP)
		local dh = dt*REGEN_RATE*Humanoid.MaxHealth
		Humanoid.Health = math.min(Humanoid.Health + dh, Humanoid.MaxHealth)
	end
	Humanoid.HealthChanged:Wait()
end