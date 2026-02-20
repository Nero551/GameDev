local players = game:GetService("Players")
local repstor = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local stateService = require(repstor.Modules.StateService)
local StateHandler = require(repstor.Modules.StateHandler)
local AIService = require(script.Parent.Parent.Services.AIService)
local Connections = require(repstor.Modules.Connections)

local updateRate = 0.025
---Player---
local elapsed = 0
runService.Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed < updateRate then return end
	elapsed = 0

	for _, player in pairs(players:GetPlayers()) do
		local character = player.Character
		if character then
			------Death Handler------
			if stateService.checkState(character,"Dead") then
				Connections:RemoveConnection(character, "Character", "StateHandler")
				return
			end
			StateHandler:HandleStates(character)
		end
	end
end)

local playerInfo = require(script.Parent.Parent.Modules.Utilities.PlayerInfo)
players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		playerInfo:UpdateInfo(player, char)
	end)
end)