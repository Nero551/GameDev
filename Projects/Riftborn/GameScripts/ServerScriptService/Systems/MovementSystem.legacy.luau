local repstor = game:GetService("ReplicatedStorage")
local remotes = repstor.Remotes
local MovementService = require(script.Parent.Parent.Services.MovementService)

MovementService:MainStates()

remotes.Sprint.OnServerEvent:Connect(function(player:Player, character)
	MovementService:Sprint(character)
end)

---Dash---
remotes.Dash.OnServerEvent:Connect(function(player:Player, direction, IsShiftLockOff)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:Dash(player, direction, IsShiftLockOff)
end)

---Flashstep--
remotes.FlashStep.OnServerEvent:Connect(function(player:Player, flashstepChage)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:FlashStep(character, flashstepChage)
end)

---WallRun---
remotes.WallRun.OnServerEvent:Connect(function(player:Player)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:WallRun(character)
end)