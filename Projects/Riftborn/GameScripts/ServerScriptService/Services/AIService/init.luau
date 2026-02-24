local PathFindingService = game:GetService("PathfindingService")

local StateService = require(game.ReplicatedStorage.Modules.StateService)
local StateHandler = require(script.Parent.Parent.Modules.Utilities.StateHandler)

local CombatService = require(script.Parent.Parent.Services.CombatService)
local AbilityService = require(script.Parent.Parent.Services.AbilityService)
local MovementService = require(script.Parent.Parent.Services.MovementService)
local CharacterVitalsService = require(script.Parent.Parent.Services.CharacterVitalsService)

local ActionVerifier = require(game.ReplicatedStorage.Modules.ActionVerifier)

local animationsFolder = game.ReplicatedStorage.Assets.Shared.Animations
local animationsModule = require(game.ReplicatedStorage.Modules.Animations)

local abilityDataModule = require(game.ReplicatedStorage.Modules.Data.AbilityData)
local StateService = require(game.ReplicatedStorage.Modules.StateService)

local AIService = {}
AIService.ActiveAIs = {}
local ActionModules = {}
local CanDoAction = require(script.CanDoAction)

for _,module in script:GetChildren() do
	if module:IsA("ModuleScript") then
		ActionModules[module.Name] = require(module)
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

function AIService:CreateAI(npc, mobData)
	AIService.ActiveAIs[npc] = {
		Root = npc:WaitForChild("HumanoidRootPart"),
		Humanoid = npc:WaitForChild("Humanoid"),
		State = "Idle",
		Target = nil,
		Tool = mobData.Tool,
		DetectionRange = mobData.DetectionRange,
		AttackRange = mobData.AttackRange,
		WanderRadius = mobData.WanderRadius,
		
		LastAttackSeenTime = 0,
		Moving = false,
		
		WalkSpeed = mobData.WalkSpeed,
		RunSpeed = mobData.RunSpeed,
		
		Damage = mobData.Damage,
		
		AbilityData = abilityDataModule.getAbilityData(mobData.Tool.Name),
		
		IdleAnimation = animationsModule:GetAnimation(npc.Humanoid.Animator,
			"Weapons."..mobData.Tool.Name..".Animations.Idle" or "Shared.Animations.Idle.Default"),
		
		WalkAnimation = animationsModule:GetAnimation(npc.Humanoid.Animator,
			"Weapons."..mobData.Tool.Name..".Animations.Walk" or "Shared.Animations.Walk.Default"),
		
		RunAnimation = animationsModule:GetAnimation(npc.Humanoid.Animator,
			"Weapons."..mobData.Tool.Name..".Animations.Run" or "Shared.Animations.Run.Default"),
	}	
end


function AIService:EnemyBrain(npc)
	
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	AIService:StateUpdater(npc)
	AIService:AcquireTarget(npc)
	
	print(AIData.Moving)
	
	if CharacterVitalsService:GetVital(npc, "Health").CurrentHealth <= 0 then
		AIData.State = "Dead"
	end
	
	if not AIData.Target then
		AIData.State = "Idle"
		return
	end
	
	if CanDoAction:BlockBroken(AIData) then
		AIData.State = "BlockBroken" 
		return
	end
	
	if CanDoAction:CanUnBlock(AIData) then
		AIData.State = "UnBlock" 
		return
	end
	
	if CanDoAction:CanBlock(AIData) then
		AIData.State = "Block"
		return
	end
	
	if CanDoAction:CanAttack(AIData) then
		AIData.State = "Attack" 
		return
	end
	
	if CanDoAction:CanRun(AIData) then
		AIData.State = "Run"
		print(AIData.State)
		return
	end
end

function AIService:StateUpdater(npc)
	local AIData = AIService.ActiveAIs[npc]
	if not AIData then return end
	
	if AIData.State == "Dead" then
		AIService:DestroyAI(npc)
	end
	
	if ActionModules[AIData.State] then
		ActionModules[AIData.State](npc)
	end
end

function AIService:DestroyAI(npc)
	AIService.ActiveAIs[npc] = nil
end


return AIService
