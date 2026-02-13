local players = game:GetService("Players")
local repstor = game:GetService("ReplicatedStorage")


local CamVectors = {}
_G.CamVectors = CamVectors

players.PlayerAdded:Connect(function(player:Player)
	CamVectors[player] = {}
end)

repstor.Remotes.UpdateCamVectors.OnServerEvent:Connect(function(player:Player, camLookVector, camRightVector)
	CamVectors[player].LookVector = camLookVector
	CamVectors[player].RightVector = camRightVector
end)