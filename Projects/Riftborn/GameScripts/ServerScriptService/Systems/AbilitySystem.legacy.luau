local replicatedStorage = game:GetService("ReplicatedStorage")
local modules  = replicatedStorage.Modules
local stateService = require(modules.StateService)
local remotes = replicatedStorage.Remotes
local AbilityService = require(script.Parent.Parent.Services.AbilityService)

remotes.Ability.OnServerEvent:Connect(function(player:Player, mouse , input)
	local char = player.Character or player.CharacterAdded:Wait()
	local tool = char:FindFirstChildWhichIsA("Tool")
	if not tool then return end
	AbilityService.AbilityUse(player ,char , tool, mouse, input)
end)