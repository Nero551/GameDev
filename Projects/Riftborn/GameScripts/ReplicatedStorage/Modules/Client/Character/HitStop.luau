return function()
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local hitstopEvent = replicatedStorage.Remotes:WaitForChild("Hitstop")

	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

	hitstopEvent.OnClientEvent:Connect(function(duration)

		local character = player.Character
		if not character then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local animator:Animator = humanoid.Animator
		if not humanoid then return end

		-- Get all playing animation tracks
		local tracks = animator:GetPlayingAnimationTracks()

		-- Pause animations
		for _, track in ipairs(tracks) do
			track:AdjustSpeed(0)
		end

		-- Wait hitstop duration
		task.wait(duration)

		-- Resume animations
		for _, track in ipairs(tracks) do
			track:AdjustSpeed(1)
		end
	end)
end