--CombatSystem
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = replicatedStorage.Remotes
local CombatService = require(script.Parent.Parent.Services.CombatService)

players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		CombatService:Spawn(character)
		CombatService:Died(character)
	end)
end)
 
remotes.Block.OnServerEvent:Connect(function(player:Player, boolean:boolean)
	local character = player.Character or player.CharacterAdded:Wait()
	CombatService:Block(character, boolean, nil)
end)


remotes.Attack.OnServerEvent:Connect(function(player:Player, argumentData)
	local character = player.Character or player.CharacterAdded:Wait()
	CombatService:Attack(character, nil, player)
end)

