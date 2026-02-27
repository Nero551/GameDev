return function()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local runService = game:GetService("RunService")
local Connections = require(ReplicatedStorage.Modules.Connections)
	local remotes = replicatedStorage.Remotes

	local cam = workspace.CurrentCamera
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	
	local elapsed = 0
	local debounce = 0.05
	Connections:AddConnection(char, "Character", "CamVectorsUpdater", runService.RenderStepped:Connect(function(dt)
		elapsed = elapsed + dt
		
		if elapsed >= debounce then
			remotes.UpdateCamVectors:FireServer(cam.CFrame.LookVector, cam.CFrame.RightVector)
			elapsed = 0
		end
	end))
end