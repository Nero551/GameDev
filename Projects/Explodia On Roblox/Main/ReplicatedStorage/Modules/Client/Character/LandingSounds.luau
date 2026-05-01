local RunService = game:GetService("RunService")
local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)
return function()
	local Player = game:GetService("Players").LocalPlayer
	local char = Player.Character or Player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")

	local humanoid: Humanoid = char:WaitForChild("Humanoid")
	local materialSounds = game.ReplicatedStorage.Assets.Core.LandingSounds

	local elapsed = 0
	local minFalltime = 2

	Connections:AddConnection(
		char,
		"Character",
		"LandingSounds",
		RunService.RenderStepped:Connect(function(dt)
			if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
				elapsed = elapsed + dt
			else
				elapsed = 0
			end

			if elapsed >= minFalltime then
				if humanoid:GetState() == Enum.HumanoidStateType.Landed then
					local materialSound: Sound = materialSounds:FindFirstChild(humanoid.FloorMaterial.Name):Clone()
					materialSound.Parent = root
					if materialSound then
						---Randomize Pitch and Volume Based On Velocity---
						local fallVelocity = math.abs(root.Velocity.Y)
						local maxVelocity = 100
						materialSound.Volume = math.clamp(fallVelocity / maxVelocity, 0.3, 1)
						materialSound.PlaybackSpeed = 1 + math.random(-5, 5) / 100
						materialSound:Play()
					end
				end
			end
		end)
	)
end
