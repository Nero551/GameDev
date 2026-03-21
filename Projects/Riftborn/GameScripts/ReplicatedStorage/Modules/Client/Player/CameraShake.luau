local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local NetworkingService = ModuleLoader:Load("Shared", "NetworkingService")
return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local Connections = ModuleLoader:Load("Shared", "Connections")
	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local camera = workspace.CurrentCamera
	
	NetworkingService:OnClientEvent("CameraShake", function(shakeIntensity)
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
