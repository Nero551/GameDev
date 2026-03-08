return function(npc)
	if not npc then
		warn("Invalid NPC")
		return
	end
	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ServerScriptService = game:GetService("ServerScriptService")

	local Animations = require(ReplicatedStorage.Modules.Animations)
	local MobData = require(ReplicatedStorage.Modules.Data.MobData)
	local uiModules = ReplicatedStorage.Modules.UI

	local AIService = require(ServerScriptService.Services.AIService)
	local CharacterVitalsService = require(ServerScriptService.Services.CharacterVitalsService)

	local GameEvents = require(ReplicatedStorage.Modules.GameEvents)
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

	---NPC Info GUI---
	local npcInfo = npc.NPCInfo
	npcInfo.Enabled = true
	local hpBG = npcInfo.NPCHealth
	npcInfo.Adornee = npc.Head

	local hpChanger = require(uiModules.HPChangerUI)
	hpChanger(hpBG, npc)

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
