local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
return function()
	local NetworkingService = ModuleLoader:Load("Shared", "NetworkingService")

	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

	NetworkingService:OnClientEvent("Hitstop", function(duration)

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
