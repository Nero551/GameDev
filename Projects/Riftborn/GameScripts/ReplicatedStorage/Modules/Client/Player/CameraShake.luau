return function()
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local Connections = require(replicatedStorage.Modules.Connections)
	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local camera = workspace.CurrentCamera
	
	replicatedStorage.Remotes.CameraShake.OnClientEvent:Connect(function(shakeIntensity)
		Connections:AddConnection(char, "Character", "CameraShake", RunService.RenderStepped:Connect(function(dt)
			if shakeIntensity > 0 then
				local offset = Vector3.new(
					(math.random() - 0.5) * 2,
					(math.random() - 0.5) * 2,
					(math.random() - 0.5) * 2
				) * shakeIntensity

				camera.CFrame = camera.CFrame * CFrame.new(offset)

				shakeIntensity = math.max(shakeIntensity - 5 * dt, 0)
				
			else
				Connections:RemoveConnection(char, "Character", "CameraShake")
			end
		end))
	end)
end