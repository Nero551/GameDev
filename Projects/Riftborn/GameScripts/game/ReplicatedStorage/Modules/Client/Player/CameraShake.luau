return function()
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	
	replicatedStorage.Remotes.CameraShake.OnClientEvent:Connect(function(shakeIntensity)
		
		local conn = nil
		conn = RunService.RenderStepped:Connect(function(dt)
			if shakeIntensity > 0 then
				local offset = Vector3.new(
					(math.random() - 0.5) * 2,
					(math.random() - 0.5) * 2,
					(math.random() - 0.5) * 2
				) * shakeIntensity

				camera.CFrame = camera.CFrame * CFrame.new(offset)

				shakeIntensity = math.max(shakeIntensity - 5 * dt, 0)
				
			else
				conn:Disconnect()
				conn = nil
			end
		end)
		
	end)
end