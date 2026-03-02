local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MobData = require(ReplicatedStorage.Modules.Data.MobData)


	local animations = require(ReplicatedStorage.Modules.Animations)
	local uiModules = ReplicatedStorage.Modules.UI


	local AIService = require(ServerScriptService.Services.AIService)
	local CharacterVitalsService = require(ServerScriptService.Services.CharacterVitalsService)

	local GameEvents = require(ReplicatedStorage.Modules.GameEvents)

local NPCService = {}

NPCService.SpawnedNPCS = {
	Boss = {},
	Enemy = {},
}


function NPCService:RegisterNPC(NPC)
    if NPC:IsA("Model") then
        if NPCService.SpawnedNPCS[MobData.Mobs[NPC.Name].Type][NPC] then return end
		NPC:SetAttribute("Type", MobData.Mobs[NPC.Name].Type)
		NPCService.SpawnedNPCS[MobData.Mobs[NPC.Name].Type][NPC] = true
		NPCService:HandleNPC(NPC)
	end
end

function NPCService:UnRegisterNPC(NPC)
    if NPC:IsA("Model") then
        if not NPCService.SpawnedNPCS[MobData.Mobs[NPC.Name].Type][NPC] then return end
		NPCService.SpawnedNPCS[MobData.Mobs[NPC.Name].Type][NPC] = nil
	end
end

print(NPCService.SpawnedNPCS)

function NPCService:HandleNPC(npc)
	local npcHumanoid = npc:WaitForChild("Humanoid")
	local animator:Animator = npcHumanoid.Animator

	local mobData = MobData.Mobs[npc.Name]
	local toolName = mobData.Tool.Name

	local toolAnims = ReplicatedStorage.Assets.Weapons[toolName].Animations
	animations:loadAnims(animator, toolAnims)
	
	AIService:CreateAI(npc, mobData)

	local npcVitals = CharacterVitalsService:Create(npc)		
	npcVitals.Health.MaxHealth = mobData.Health
	npcVitals.Health.CurrentHealth = mobData.Health


	if ReplicatedStorage.Assets.Weapons[toolName].Model:FindFirstChild(toolName.."_Equipped") then
		local toolModel:Model = ReplicatedStorage.Assets.Weapons[toolName].Model[toolName.."_Equipped"]:Clone()
		toolModel.Parent = npc
		local weld = toolModel:FindFirstChildWhichIsA("Motor6D")
		weld.Part0 = npc:FindFirstChild("Right Arm")
	end

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

	npcInfo.Adornee = npc.Head

	if npcVitals then
		local hpChanger = require(uiModules.HPChanger)
		hpChanger(hpBG, npc)
	end
	npcInfo.NPCLevel.LevelText.Text = mobData.Level
	npcInfo.NPCName.Text = npc.Name
end

return NPCService
