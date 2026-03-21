local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local StateHandler = require(ServerScriptService.Modules.Utilities.StateHandler)
local CharacterVitalsService = require(ServerScriptService.Services.Combat.CharacterVitalsService)
local HandService = require(ServerScriptService.Services.Combat.HandService)
local Connections = require(ReplicatedStorage.Modules.Core.Connections)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local StateChecker = require(ReplicatedStorage.Modules.Helpers.StateChecker)
local StateService = require(ServerScriptService.Services.Core.StateService)
local MovementService = require(game.ServerScriptService.Services.Combat.MovementService)
local CombatService = require(game.ServerScriptService.Services.Combat.CombatService)
local RegenService = require(game.ServerScriptService.Services.Combat.RegenService)
local AbilityService = require(game.ServerScriptService.Services.Combat.AbilityService)
local TimeService = require(game.ServerScriptService.Services.World.TimeService)

----------------------------------------------------------------------------------------------------------------------------------
local elapsed = 0
local updateRate = 0.05
---Regen Stuff , Time Cycle and Handling States---
RunService.Heartbeat:Connect(function(dt)
	
	RegenService:ManaRegen(dt)
	RegenService:HealthRegen(dt)
	RegenService:FlashStepRegen(dt)
	RegenService:BlockCounterRegen(dt)
	TimeService:TimeCycle(dt)
	
	elapsed += dt
	if elapsed > updateRate then
		elapsed = 0
		for _, player in pairs(Players:GetPlayers()) do
			local character = player.Character
			if character then
				------Death Handler------
				if StateChecker:CheckState(character,"Dead") then
					Connections:RemoveConnection(character, "Character", "StateHandler")
					continue
				end
				StateHandler:HandleStates(character,dt)		
			end
		end
	end
end)

--local PlayerInfoGui = require(script.Parent.Parent.Modules.Utilities.PlayerInfoGui)
--Players.PlayerAdded:Connect(function(player)
--	player.CharacterAdded:Connect(function(char)
--		PlayerInfoGui:UpdateInfo(player, char)
--	end)
--end)

----------------------------------------------------------------------------------------------------------------------------------
---Creating Status For Player On Spawn---
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		StateService:Create(character)
	end)
	player.CharacterRemoving:Connect(function(character)
		CharacterVitalsService:Cleanup(character)
	end)
end)
---Destroying Status For Player On Leave---
Players.PlayerRemoving:Connect(function(player)
	if not player.Character then return end 
	StateService:Destroy(player.Character)
end)
----------------------------------------------------------------------------------------------------------------------------------

MovementService:LoadSharedAnimations()

---Client Requests to Sprint---
NetworkingService:OnServerEvent("Sprint", function(player:Player)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:Sprint(character)
end)

---Client Requests to Dash---
NetworkingService:OnServerEvent("Dash", function(player:Player, direction, IsShiftLockOff)
	MovementService:Dash(player, direction, IsShiftLockOff)
end)

---Client Requests to Flashstep---
NetworkingService:OnServerEvent("FlashStep", function(player:Player)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:FlashStep(character)
end)

---Client Requests to WallRun---
NetworkingService:OnServerEvent("WallRun", function(player:Player)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:WallRun(character)
end)


----------------------------------------------------------------------------------------------------------------------------------

---Death and Spawn---
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		CombatService:Spawn(character)
		CombatService:Died(character)
	end)
end)

---Client Requests to Block---
NetworkingService:OnServerEvent("Block", function(player:Player, boolean:boolean)
	local character = player.Character or player.CharacterAdded:Wait()
	CombatService:Block(character, boolean, nil)
end)

---Client Requests to Attack---
NetworkingService:OnServerEvent("Attack", function(player:Player)
	local character = player.Character or player.CharacterAdded:Wait()
	CombatService:Attack(character, nil, player)
end)

NetworkingService:OnServerEvent("RequestPutInHand", function(player,toolId)
	HandService:PutInHand(player, toolId)
end)

NetworkingService:OnServerEvent("RequestRemoveFromHand", function(player,toolId)
	HandService:RemoveFromHand(player, toolId)
end)

----------------------------------------------------------------------------------------------------------------------------------

---Client Requests to use Ability---
NetworkingService:OnServerEvent("Ability", function(player:Player, mouse , input)
	local char = player.Character or player.CharacterAdded:Wait()
	local tool = char:FindFirstChildWhichIsA("Tool")
	AbilityService:UseAbility(player ,char , tool, mouse, input)
end)


----------------------------------------------------------------------------------------------------------------------------------


