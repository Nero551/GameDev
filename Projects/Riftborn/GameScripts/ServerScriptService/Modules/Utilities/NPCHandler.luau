local NPCHandler = {}

function NPCHandler:HandleNPC(npc)
	local ServerScriptService = game:GetService("ServerScriptService")
	local repstor = game:GetService("ReplicatedStorage")
	local players = game:GetService("Players")
	local tween = game:GetService("TweenService")

	local StateService = require(repstor.Modules.StateService)
	local animations = require(repstor.Modules.Animations)
	local uiModules = repstor.Modules.UI


	local AIModule = require(ServerScriptService.Services.AIService)
	local CharacterVitalsService = require(ServerScriptService.Services.CharacterVitalsService)
	
	local GameEvents = require(repstor.Modules.GameEvents)
	local MobData = require(repstor.Modules.Data.MobData)

	local npcHumanoid = npc:WaitForChild("Humanoid")
	local animator:Animator = npcHumanoid.Animator
	
	local config = MobData.Mobs[npc.Name]
	local toolName = config.Tool.Name
	
	local toolAnims = repstor.Assets.Weapons[toolName].Animations
	animations:loadAnims(animator, toolAnims)
	
	local npcVitals = CharacterVitalsService:Create(npc)		
	npcVitals.Health.MaxHealth = config.Health
	npcVitals.Health.CurrentHealth = config.Health
	
	
	if repstor.Assets.Weapons[toolName].Model:FindFirstChild(toolName.."_Equipped") then
		local toolModel:Model? = repstor.Assets.Weapons[toolName].Model[toolName.."_Equipped"]:Clone()
		toolModel.Parent = npc
		local weld:Motor6D = toolModel:FindFirstChildWhichIsA("Motor6D")
		weld.Part0 = npc:FindFirstChild("Right Arm")
	end
	

	---StatusFolder---
	local statusFolder =  Instance.new("Folder")
	statusFolder.Name = "Status"
	statusFolder.Parent = npc
	local BlockCounter = Instance.new("IntValue")
	BlockCounter.Parent = statusFolder
	BlockCounter.Name = "BlockCounter"
	BlockCounter.Value = 0

	---FlashStepCharges---
	local flashstepCharge = Instance.new("IntValue")
	flashstepCharge.Parent = statusFolder
	flashstepCharge.Name = "FlashStepCharge"
	flashstepCharge.Value = 3

	task.spawn(function()
		while true do
			flashstepCharge.Value = math.clamp(flashstepCharge.Value, 0, 3)
			task.wait(15)
			flashstepCharge.Value = flashstepCharge.Value + 1
			flashstepCharge.Value = math.clamp(flashstepCharge.Value, 0, 3)
		end
	end)


	local animations = {}
	if toolName then
		animations = {
			Idle = "Weapons."..toolName..".Animations.Idle",
			Walk = "Weapons."..toolName..".Animations.Walk",
			Run  = "Weapons."..toolName..".Animations.Run",
		}
	end

	local Abilities = {
		Z = toolName.."Z",
		X = toolName.."X",
		C = toolName.."C",
		V = toolName.."V",
		B = toolName.."B",
	}



	---Running The AI---
	local npcAI = AIModule:CreateAI(npc, config, animations, Abilities)
	local Drops = config.Drops

	local function isNearPlayer(npc)
		for _, player in pairs(game.Players:GetPlayers()) do
			if player.Character and (npc.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude < 1000 then
				return true
			end
		end
		return false
	end

	task.spawn(function()
		while not StateService.checkState(npc, "Dead") do
			if isNearPlayer(npc) then
				wait(0.1) 
				npcAI:EnemyBrain()
				npcAI:UpdateState()
			else
				wait(1)
			end
		end
	end)


	---When NPC Die---
	local deathAnimation = animator:LoadAnimation(game.ReplicatedStorage.Assets.Shared.Character.Death)

	npc.Humanoid.Died:Connect(function()
		deathAnimation:Play()

		for _,KillerHit in npcHumanoid:GetChildren() do
			if KillerHit.Name == "KillerHit" and KillerHit:IsA("ObjectValue") then
				local KillerPlayer = KillerHit.Value
				GameEvents.GiveRewards:Fire(KillerPlayer, Drops, false)
				GameEvents.MobKilled:Fire(KillerPlayer, npc.Name)
			end
		end
		task.delay(10,function()
			npc:Destroy()
		end)
	end)



	---NPC Info GUI---
	local npcInfo = npc.NPCInfo
	local hpBG = npcInfo.NPCHealth
	local hpText = npcInfo.NPCHealth.HealthNumber

	npcInfo.Adornee = npc.Head
	
	if npcVitals then
		local hpChanger = require(uiModules.HPChanger)
		hpChanger(hpBG, npc)
	end
	


	npcInfo.NPCLevel.LevelText.Text = config.Level
	npcInfo.NPCName.Text = npc.Name
end

return NPCHandler
