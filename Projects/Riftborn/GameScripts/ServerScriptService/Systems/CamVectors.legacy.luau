local CharacterVitalsSerice = require(script.Parent.Parent.Services.CharacterVitalsService)


game.ReplicatedStorage.Remotes.UpdateCamVectors.OnServerEvent:Connect(function(player,camLookVector, camRightVector)
	local char = player.Character or player.CharacterAdded:Wait()
	CharacterVitalsSerice:ModifyVital(char, "CamVectors", "UpdateCamVectors", {
		["CamRightVector"] = camRightVector,
		["CamLookVector"] = camLookVector,	
	})
end)
