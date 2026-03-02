local ServerScriptService = game:GetService("ServerScriptService")
local repstor = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local remotes = repstor.Remotes

local StateService = require(ServerScriptService.Services.StateService)
local MovementService = require(script.Parent.Parent.Services.MovementService)
local CombatService = require(script.Parent.Parent.Services.CombatService)
local RegenService = require(script.Parent.Parent.Services.RegenService)
local AbilityService = require(script.Parent.Parent.Services.AbilityService)
local CharacterVitalsSerice = require(script.Parent.Parent.Services.CharacterVitalsService)
local TimeService = require(script.Parent.Parent.Services.TimeService)

----------------------------------------------------------------------------------------------------------------------------------

---Regen Stuff and Time Cycle---
runService.Heartbeat:Connect(function(dt)
	RegenService:ManaRegen(dt)
	RegenService:HealthRegen(dt)
	RegenService:FlashStepRegen(dt)
	RegenService:BlockCounterRegen(dt)
	TimeService:TimeCycle(dt)
end)


----------------------------------------------------------------------------------------------------------------------------------
---Creating Status For Player On Spawn---
players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		StateService:Create(character)
	end)
end)
---Destroying Status For Player On Leave---
players.PlayerRemoving:Connect(function(player)
	if not player.character then return end 
	StateService:Destroy(player.Character)
end)
----------------------------------------------------------------------------------------------------------------------------------

MovementService:LoadSharedAnimations()

---Client Requests to Sprint---
remotes.Sprint.OnServerEvent:Connect(function(player:Player, character)
	MovementService:Sprint(character)
end)

---Client Requests to Dash---
remotes.Dash.OnServerEvent:Connect(function(player:Player, direction, IsShiftLockOff)
	MovementService:Dash(player, direction, IsShiftLockOff)
end)

---Client Requests to Flashstep---
remotes.FlashStep.OnServerEvent:Connect(function(player:Player, flashstepChage)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:FlashStep(character)
end)

---Client Requests to WallRun---
remotes.WallRun.OnServerEvent:Connect(function(player:Player)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:WallRun(character)
end)


----------------------------------------------------------------------------------------------------------------------------------

players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		CombatService:Spawn(character)
		CombatService:Died(character)
	end)
end)

---Client Requests to Block---
remotes.Block.OnServerEvent:Connect(function(player:Player, boolean:boolean)
	local character = player.Character or player.CharacterAdded:Wait()
	CombatService:Block(character, boolean, nil)
end)

---Client Requests to Attack---
remotes.Attack.OnServerEvent:Connect(function(player:Player, argumentData)
	local character = player.Character or player.CharacterAdded:Wait()
	CombatService:Attack(character, nil, player)
end)


----------------------------------------------------------------------------------------------------------------------------------

---Client Requests to use Ability---
remotes.Ability.OnServerEvent:Connect(function(player:Player, mouse , input)
	local char = player.Character or player.CharacterAdded:Wait()
	local tool = char:FindFirstChildWhichIsA("Tool")
	AbilityService:UseAbility(player ,char , tool, mouse, input)
end)


----------------------------------------------------------------------------------------------------------------------------------

---Update CamVectors---
remotes.UpdateCamVectors.OnServerEvent:Connect(function(player,camLookVector, camRightVector)
	local char = player.Character or player.CharacterAdded:Wait()
	CharacterVitalsSerice:ModifyVital(char, "CamVectors", "UpdateCamVectors", {
		["CamRightVector"] = camRightVector,
		["CamLookVector"] = camLookVector,	
	})
end)


----------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------