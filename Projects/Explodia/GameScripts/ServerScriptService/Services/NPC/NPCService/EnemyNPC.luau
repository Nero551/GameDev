return function(npc)
	if not npc then
		warn("Invalid NPC")
		return
	end
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)
	local MobData = require(game.ReplicatedStorage.Modules.Data.MobData)

	local AIService = require(game.ServerScriptService.Services.NPC.AIService)
	local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)

	local GameEvents = require(game.ReplicatedStorage.Modules.Core.GameEvents)
	local npcHumanoid = npc:WaitForChild("Humanoid")
	local animator: Animator = npcHumanoid.Animator

	local mobData = MobData.Mobs[npc.Name]
	local toolName = mobData.Tool.Name

	AIService:CreateAI(npc)

	if ReplicatedStorage.Assets.Weapons[toolName].Model:FindFirstChild(toolName .. "_Equipped") then
		local toolModel: Model = ReplicatedStorage.Assets.Weapons[toolName].Model[toolName .. "_Equipped"]:Clone()
		toolModel.Parent = npc
		local weld = toolModel:FindFirstChildWhichIsA("Motor6D")
		weld.Part0 = npc:FindFirstChild("Right Arm")
	end

	---NPC Info GUI---m
	local npcInfo = npc.NPCInfo
	npcInfo.Enabled = true
	npcInfo.Adornee = npc.Head

	--local HPChangerUI = require(uiModules.HPChangerUI)
	--HPChangerUI(hpBG, npc)

	npcInfo.NPCLevel.LevelText.Text = mobData.Level
	npcInfo.NPCName.Text = npc.Name

	---When NPC Die---
	local deathAnimation = Animations:GetAnimation(animator, "Shared.Character.Death")
	local alreadyDead = false
	npc:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(function()
		if alreadyDead == true then
			return
		end
		if CharacterVitalsService:GetVital(npc, "Health").CurrentHealth <= 0 then
			alreadyDead = true
			npcInfo.Enabled = false
			deathAnimation:Play()
			for _, KillerHit in npcHumanoid:GetChildren() do
				if KillerHit.Name == "KillerHit" and KillerHit:IsA("ObjectValue") then
					local KillerPlayer = KillerHit.Value
					GameEvents.MobKilled:Fire(KillerPlayer, npc.Name)
				end
			end
			Debris:AddItem(npc, 10)
		end
	end)
end
