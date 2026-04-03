local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CombatService = require(ServerScriptService.Services.Combat.CombatService)
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local StateHandler = require(game.ServerScriptService.Modules.Utilities.StateHandler)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)
local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)
local TechniqueData = require(game.ReplicatedStorage.Modules.Data.TechniqueData)
local MobData = require(game.ReplicatedStorage.Modules.Data.MobData)

local StateService = require(game.ServerScriptService.Services.Core.StateService)

local AIService = {}
AIService.ActiveAIs = {}
local ActionModules = {}
AIService.Brains = {}

for _, module in script:GetChildren() do
	if module:IsA("ModuleScript") then
		ActionModules[module.Name] = require(module)
	end
end

for _, module in script.Brains:GetChildren() do
	if module:IsA("ModuleScript") then
		AIService.Brains[module.Name] = require(module)
	end
end

function AIService:AcquireTarget(npc)
	local nearestPlayer = nil
	local closestDist = math.huge

	local AIData = AIService.ActiveAIs[npc]
	if not AIData then
		return
	end

	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (AIData.Root.Position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance < AIData.DetectionRange and distance < closestDist then
				if VitalsService:GetVital(player.Character, "Health").CurrentHealth > 0 then
					nearestPlayer = player.Character.PrimaryPart
					closestDist = distance
				end
			end
		end
	end
	AIData.Target = nearestPlayer
end

--* Creates AI
function AIService:CreateAI(npc)
	local mobData = MobData.Mobs[npc.Name]
	local itemData = ItemDataBase:GetItemData(mobData.Tool)
	if itemData then
		Animations:LoadAnimations(npc.Humanoid, ReplicatedStorage.Assets.Weapons[itemData.Name].Animations)
	end

	StateService:Create(npc)
	AIService.ActiveAIs[npc] = {
		Root = npc:WaitForChild("HumanoidRootPart"),
		Humanoid = npc:WaitForChild("Humanoid"),
		Type = mobData.Type,
		Tool = mobData.Tool,
		State = "Idle",

		Target = nil,
		AggroList = {}, -- (does nothing  yet)
		DamageTaken = {}, -- (does nothing  yet)
		LastAttackSeenTime = 0,

		DetectionRange = mobData.DetectionRange,
		AttackRange = mobData.AttackRange,
		WanderRadius = mobData.WanderRadius,

		Moving = false,
		NeedsRepath = 0,
		Path = nil,

		WalkSpeed = mobData.WalkSpeed,
		RunSpeed = mobData.RunSpeed,

		Techniques = {
			-- TechniqueData:GetTechniqueData(itemData.Abilities.Z),
			-- TechniqueData:GetTechniqueData(itemData.Abilities.X),
			-- TechniqueData:GetTechniqueData(itemData.Abilities.C),
		},
		ChosenTechnique = nil,

		IdleAnimation = Animations:GetAnimation(
			npc.Humanoid,
			"Weapons." .. itemData.Name .. ".Animations.Idle" or "Shared.Animations.Idle.Default"
		),
		WalkAnimation = Animations:GetAnimation(
			npc.Humanoid,
			"Weapons." .. itemData.Name .. ".Animations.Walk" or "Shared.Animations.Walk.Default"
		),
		RunAnimation = Animations:GetAnimation(
			npc.Humanoid,
			"Weapons." .. itemData.Name .. ".Animations.Run" or "Shared.Animations.Run.Default"
		),
	}
end

function AIService:StateUpdater(npc, updateRate)
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then
		return
	end

	if AIData.State == "Dead" then
		for _, anim in pairs(Animations.loadedAnimations[npc]) do
			if anim.IsPlaying then
				anim:Stop()
			end
		end
		CombatService:Died(npc)
		AIService:DestroyAI(npc)
		return
	end

	if ActionModules[AIData.State] then
		ActionModules[AIData.State](npc)
	end
	StateHandler:HandleStates(npc, updateRate, AIData.RunSpeed)
end

function AIService:DestroyAI(npc)
	Connections:CleanupConnections(npc)
	AIService.ActiveAIs[npc] = nil
end

return AIService
