local NPCHandler = {}

function NPCHandler:HandleNPC(npc)
	local ServerScriptService = game:GetService("ServerScriptService")
	local repstor = game:GetService("ReplicatedStorage")
	local players = game:GetService("Players")
	local tween = game:GetService("TweenService")

	local StateService = require(repstor.Modules.StateService)


	local AIModule = require(ServerScriptService.Services.AIService)
	local GameEvents = require(repstor.Modules.GameEvents)
	local MobData = require(repstor.Modules.Data.MobData)

	local npcHumanoid = npc:WaitForChild("Humanoid")

	task.spawn(function()

		local REGEN_RATE = 1/100 -- Regenerate this fraction of MaxHealth per second.
		local REGEN_STEP = 1 -- Wait this long between each regeneration step.

		while npc and npcHumanoid do
			if not StateService.checkState(npc, "In Combat") and npcHumanoid.Health < npcHumanoid.MaxHealth then
				local dh = REGEN_STEP * REGEN_RATE * npcHumanoid.MaxHealth
				npcHumanoid.Health = math.min(npcHumanoid.Health + dh, npcHumanoid.MaxHealth)
			end
			task.wait(REGEN_STEP)
		end
	end)

	local config = MobData.Mobs[npc.Name]
	local toolName = config.Tool.Name

	npcHumanoid.MaxHealth = config.Health
	npcHumanoid.Health = config.Health
	
	local toolModel:Model? = repstor.Assets.Weapons[toolName].Model[toolName.."_Equipped"]:Clone()
	toolModel.Parent = npc
	local weld:Motor6D = toolModel:FindFirstChildWhichIsA("Motor6D")
	weld.Part0 = npc:FindFirstChild("Right Arm")



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
		while npcHumanoid.Health > 0 do
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
	local animator:Animator = npcHumanoid.Animator
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
	local hpBar = npcInfo.NPCHealth.HealthFill
	local hpText = npcInfo.NPCHealth.HealthNumber

	npcInfo.Adornee = npc.Head

	local function HpChanger()
		local info = TweenInfo.new(0.04, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
		tween:Create(hpBar, info , {Size = UDim2.fromScale(npcHumanoid.Health/npcHumanoid.MaxHealth,1)}):Play()
		hpText.Text = math.round(npcHumanoid.Health).."/"..math.round(npcHumanoid.MaxHealth)
	end

	npcHumanoid:GetPropertyChangedSignal("Health"):Connect(function()
		HpChanger()
	end)

	HpChanger()

	npcInfo.NPCLevel.LevelText.Text = config.Level
	npcInfo.NPCName.Text = npc.Name
end

return NPCHandler
