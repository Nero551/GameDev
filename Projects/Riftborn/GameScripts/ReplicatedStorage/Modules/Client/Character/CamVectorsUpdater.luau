return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local runService = game:GetService("RunService")
	local Connections = require(ReplicatedStorage.Modules.Connections)
	local NetworkingService = require(ReplicatedStorage.Modules.NetworkingService)

	local cam = workspace.CurrentCamera
	local player = game:GetService("Players").LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()

	local prevLook = nil
	local prevRight = nil

	local elapsed = 0
	local debounce = 0.05
	Connections:AddConnection(char, "Character", "CamVectorsUpdater", runService.RenderStepped:Connect(function(dt)
		elapsed = elapsed + dt
		
		if elapsed >= debounce then
			if cam.CFrame.lookVector == prevLook or cam.CFrame.RightVector == prevRight then
				elapsed  = 0
				return
			end

			prevLook = cam.CFrame.lookVector
			prevRight = cam.CFrame.RightVector
			
			NetworkingService:FireToServer("UpdateCamVectors", cam.CFrame.LookVector, cam.CFrame.RightVector)
			elapsed = 0
		end
	end))
end