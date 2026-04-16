local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local EquipService = require(ServerScriptService.Services.Profile.EquipService)
local StateHandler = require(game.ServerScriptService.Modules.Utilities.StateHandler)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)
local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local StateService = require(game.ServerScriptService.Services.Core.StateService)
local MovementService = require(game.ServerScriptService.Services.Combat.MovementService)
local CombatService = require(game.ServerScriptService.Services.Combat.CombatService)
local RegenService = require(game.ServerScriptService.Services.Combat.RegenService)
local TechniqueService = require(game.ServerScriptService.Services.Combat.TechniqueService)
local TimeService = require(game.ServerScriptService.Services.World.TimeService)

----------------------------------------------------------------------------------------------------------------------------------
local elapsed = 0
local updateRate = 0.05
---Regen Stuff , Time Cycle and Handling States---
RunService.Heartbeat:Connect(function(dt)
	RegenService:ManaRegen(dt)
	RegenService:StaminaRegen(dt)
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
				if StateChecker:CheckState(character, "Dead") then
					Connections:RemoveConnection(character, "Character", "StateHandler")
					continue
				end
				StateHandler:HandleStates(character, updateRate)
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
		VitalsService:Create(character)
		StateService:Create(character)
	end)
	player.CharacterRemoving:Connect(function(character)
		VitalsService:Cleanup(character)
		Connections:CleanupConnections(character, "Character")
	end)
end)
---Destroying Status For Player On Leave---
Players.PlayerRemoving:Connect(function(player)
	if not player.Character then
		return
	end
	StateService:Destroy(player.Character)
end)
----------------------------------------------------------------------------------------------------------------------------------

MovementService:LoadAnimations()

---Client Requests to Sprint---
NetworkingService:OnServerEvent("Sprint", function(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:Sprint(character)
end)

---Client Requests to Dash---
NetworkingService:OnServerEvent("Dash", function(player: Player, direction, IsShiftLockOff)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:Dash(character, direction, IsShiftLockOff)
end)

---Client Requests to Flashstep---
NetworkingService:OnServerEvent("FlashStep", function(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:FlashStep(character)
end)

---Client Requests to WallRun---
NetworkingService:OnServerEvent("WallRun", function(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	MovementService:WallRun(character)
end)

---Death and Spawn---
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		CombatService:Spawn(character)
		CombatService:Died(character)
	end)
end)

---Client Requests to Block---
NetworkingService:OnServerEvent("Block", function(player: Player, boolean: boolean)
	local character = player.Character or player.CharacterAdded:Wait()
	CombatService:Block(character, boolean)
end)


--! Doesnot Work Right Now
---Client Requests to Basic Attack---
NetworkingService:OnServerEvent("BasicAttack", function(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	CombatService:BasicAttack(character)
end)

---Client Requests to Heavy Attack---
NetworkingService:OnServerEvent("HeavyAttack", function(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	CombatService:HeavyAttack(character)
end)

---Client Requests To Change Item In Active Hand
NetworkingService:OnServerEvent("SetActiveHand", function(player, toolId)
	EquipService:SetActiveHand(player, toolId)
end)

---Client Requests to use Technique---
NetworkingService:OnServerEvent("Technique", function(player: Player, slot, mouse)
	local char = player.Character or player.CharacterAdded:Wait()
	TechniqueService:UseTechnique(char, slot, mouse)
end)
