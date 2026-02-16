return function()
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local runService = game:GetService("RunService")
	local remotes = replicatedStorage.Remotes

	local cam = workspace.CurrentCamera
	local player = game:GetService("Players").LocalPlayer
	
	local runService = game:GetService("RunService")
	
	local elapsed = 0
	local debounce = 0.05
	
	runService.RenderStepped:Connect(function(dt)
		elapsed = elapsed + dt
		
		if elapsed >= debounce then
			remotes.UpdateCamVectors:FireServer(cam.CFrame.LookVector, cam.CFrame.RightVector)
			elapsed = 0
		end
	end)

end