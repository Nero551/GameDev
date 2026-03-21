local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StateHandler = ModuleLoader:Load("Server", "StateHandler")
local CharacterVitalsService = ModuleLoader:Load("Server", "CharacterVitalsService")
local Animations = ModuleLoader:Load("Shared", "Animations")
local Connections = ModuleLoader:Load("Shared", "Connections")
local AbilityData = ModuleLoader:Load("Shared", "AbilityData")
local MobData = ModuleLoader:Load("Shared", "MobData")

local StateService = ModuleLoader:Load("Server", "StateService")

local AIService = {}
AIService.ActiveAIs = {}
local ActionModules = {}
AIService.Brains = {}

for _,module in script:GetChildren() do
	if module:IsA("ModuleScript") then
		ActionModules[module.Name] = ModuleLoader:Load("Server", module.Name)
	end
end

for _,module in script.Brains:GetChildren() do
	if module:IsA("ModuleScript") then
		AIService.Brains[module.Name] = ModuleLoader:Load("Server", module.Name)
	end
end

function AIService:AcquireTarget(npc)
	local nearestPlayer = nil
	local closestDist = math.huge
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (AIData.Root.Position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance < AIData.DetectionRange and distance < closestDist then
				if CharacterVitalsService:GetVital(player.Character, "Health").CurrentHealth > 0 then
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
	if mobData.Tool then
		Animations:loadAnims(npc.Humanoid.Animator,
			ReplicatedStorage.Assets.Weapons[mobData.Tool.Name].Animations)
	end
	CharacterVitalsService:Create(npc)
	CharacterVitalsService:ModifyVital(npc,"Health" , "ModifyMaxHealth", {
        ["MaxHealth"] = mobData.Health
    })		
    CharacterVitalsService:ModifyVital(npc,"Health" , "ModifyHealth", {
        ["HealthChange"] = mobData.Health
    })	
	StateService:Create(npc)
	AIService.ActiveAIs[npc] = {
		Root = npc:WaitForChild("HumanoidRootPart"),
		Humanoid = npc:WaitForChild("Humanoid"),
		Type = mobData.Type,

		State = "Idle",
		Tool = mobData.Tool,
		Target = nil,
		AggroList = {}, -- (does nothing  yet)
		DamageTaken = {}, -- (does nothing  yet)
		Drops = mobData.Drops,
		
		DetectionRange = mobData.DetectionRange,
		AttackRange = mobData.AttackRange,
		WanderRadius = mobData.WanderRadius,
		
		Moving = false,
		NeedsRepath = 0,
		WalkSpeed = mobData.WalkSpeed,
		RunSpeed = mobData.RunSpeed,
		
		LastAttackSeenTime = 0,
		Damage = mobData.Damage,
		
		Abilities = AbilityData:GetAbilityData(mobData.Tool.Name),
		ChosenAbility = nil,
		
		IdleAnimation = Animations:GetAnimation(npc.Humanoid.Animator,
			"Weapons."..mobData.Tool.Name..".Animations.Idle" or "Shared.Animations.Idle.Default"),
		
		WalkAnimation = Animations:GetAnimation(npc.Humanoid.Animator,
			"Weapons."..mobData.Tool.Name..".Animations.Walk" or "Shared.Animations.Walk.Default"),
		
		RunAnimation = Animations:GetAnimation(npc.Humanoid.Animator,
			"Weapons."..mobData.Tool.Name..".Animations.Run" or "Shared.Animations.Run.Default"),
	}	
end

function AIService:StateUpdater(npc,dt)
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	
	if AIData.State == "Dead" then
		for animName,anim in pairs(Animations.loadedAnimations[npc]) do
			if anim.IsPlaying then
				anim:Stop()
			end
		end
		AIService:DestroyAI(npc)
		return
	end
	
	if ActionModules[AIData.State] then
		ActionModules[AIData.State](npc)
	end
	StateHandler:HandleStates(npc,dt, AIData.RunSpeed)
end

function AIService:DestroyAI(npc)
	Connections:CleanupConnections(npc)
	AIService.ActiveAIs[npc] = nil
end

return AIService
