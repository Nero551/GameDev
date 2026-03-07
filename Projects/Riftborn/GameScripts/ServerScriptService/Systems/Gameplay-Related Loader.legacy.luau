local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

local StateHandler = require(ServerScriptService.Modules.Utilities.StateHandler)
local Connections = require(ReplicatedStorage.Modules.Connections)
local NetworkingService = require(ReplicatedStorage.Modules.NetworkingService)
local StateChecker = require(ReplicatedStorage.Modules.StateChecker)
local StateService = require(ServerScriptService.Services.StateService)
local MovementService = require(script.Parent.Parent.Services.MovementService)
local CombatService = require(script.Parent.Parent.Services.CombatService)
local RegenService = require(script.Parent.Parent.Services.RegenService)
local AbilityService = require(script.Parent.Parent.Services.AbilityService)
local TimeService = require(script.Parent.Parent.Services.TimeService)

----------------------------------------------------------------------------------------------------------------------------------
local elapsed = 0
local updateRate = 0.05
---Regen Stuff , Time Cycle and Handling States---
runService.Heartbeat:Connect(function(dt)
	
	RegenService:ManaRegen(dt)
	RegenService:HealthRegen(dt)
	RegenService:FlashStepRegen(dt)
	RegenService:BlockCounterRegen(dt)
	TimeService:TimeCycle(dt)
	
	elapsed += dt
	if elapsed > updateRate then
		elapsed = 0
		for _, player in pairs(players:GetPlayers()) do
			local character = player.Character
			if character then
				------Death Handler------
				if StateChecker:CheckState(character,"Dead") then
					Connections:RemoveConnection(character, "Character", "StateHandler")
					continue
				end
				StateHandler:HandleStates(character)		
			end
		end
	end
end)

local playerInfo = require(script.Parent.Parent.Modules.Utilities.PlayerInfoGui)
players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		playerInfo:UpdateInfo(player, char)
	end)
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
players.PlayerAdded:Connect(function(player)
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
NetworkingService:OnServerEvent("Attack", function(player:Player, argumentData)
	local character = player.Character or player.CharacterAdded:Wait()
	CombatService:Attack(character, nil, player)
end)


----------------------------------------------------------------------------------------------------------------------------------

---Client Requests to use Ability---
NetworkingService:OnServerEvent("Ability", function(player:Player, mouse , input)
	local char = player.Character or player.CharacterAdded:Wait()
	local tool = char:FindFirstChildWhichIsA("Tool")
	AbilityService:UseAbility(player ,char , tool, mouse, input)
end)


----------------------------------------------------------------------------------------------------------------------------------



