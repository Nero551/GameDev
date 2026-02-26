local NPCHandler = {}

function NPCHandler:HandleNPC(npc)
	local ServerScriptService = game:GetService("ServerScriptService")
	local repstor = game:GetService("ReplicatedStorage")
	local players = game:GetService("Players")
	local tween = game:GetService("TweenService")

	local StateService = require(repstor.Modules.StateService)
	local animations = require(repstor.Modules.Animations)
	local uiModules = repstor.Modules.UI


	local AIService = require(ServerScriptService.Services.AIService)
	local CharacterVitalsService = require(ServerScriptService.Services.CharacterVitalsService)

	local GameEvents = require(repstor.Modules.GameEvents)
	local MobData = require(repstor.Modules.Data.MobData)

	local npcHumanoid = npc:WaitForChild("Humanoid")
	local animator:Animator = npcHumanoid.Animator

	local mobData = MobData.Mobs[npc.Name]
	local toolName = mobData.Tool.Name

	local toolAnims = repstor.Assets.Weapons[toolName].Animations
	animations:loadAnims(animator, toolAnims)
	
	AIService:CreateAI(npc, mobData)

	local npcVitals = CharacterVitalsService:Create(npc)		
	npcVitals.Health.MaxHealth = mobData.Health
	npcVitals.Health.CurrentHealth = mobData.Health


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

	---When NPC Die---
	local Drops = mobData.Drops
	local deathAnimation = animator:LoadAnimation(game.ReplicatedStorage.Assets.Shared.Character.Death)
	local alreadyDead = false
	npc:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(function()
		if alreadyDead == true then return end
		if npc:GetAttribute("Health_CurrentHealth") <= 0 then
			alreadyDead = true
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
		end
	
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



	npcInfo.NPCLevel.LevelText.Text = mobData.Level
	npcInfo.NPCName.Text = npc.Name
end

return NPCHandler