return function()
	local Player = game:GetService("Players").LocalPlayer
	local char = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")
	local root: Part = char:WaitForChild("HumanoidRootPart")

	local Debris = game:GetService("Debris")

	local animator: Animator = humanoid.Animator
	local deathAnimation = animator:LoadAnimation(game.ReplicatedStorage.Assets.Shared.Character.Death)

	humanoid.BreakJointsOnDeath = false
	humanoid.Died:Connect(function()
		deathAnimation:Play()

		local attachment = root:FindFirstChild("Ragdoll Attachment")
		if not attachment then
			attachment = Instance.new("Attachment")
			attachment.Parent = root
			attachment.Name = "Ragdoll Attachment"
		end

		local ragdoll = Instance.new("LinearVelocity")
		ragdoll.Parent = root
		ragdoll.Attachment0 = attachment
		ragdoll.MaxForce = math.huge
		ragdoll.RelativeTo = Enum.ActuatorRelativeTo.World
		ragdoll.VectorVelocity = root.CFrame.LookVector * 5

		Debris:AddItem(ragdoll, 0.1)
	end)
end
