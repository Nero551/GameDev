return function(npc)
	if not npc then
		warn("Invalid NPC")
		return
	end

	local Debris = game:GetService("Debris")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ServerScriptService = game:GetService("ServerScriptService")
	local ServerStorage = game:GetService("ServerStorage")
	local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
	local ToolLoader = require(ServerScriptService.Modules.Utilities.ToolLoader)
	local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)
	local MobData = require(game.ReplicatedStorage.Modules.Data.MobData)

	local AIService = require(game.ServerScriptService.Services.NPC.AIService)
	local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

	local GameEvents = require(game.ReplicatedStorage.Modules.Core.GameEvents)
	local npcHumanoid = npc:WaitForChild("Humanoid")

	local mobData = MobData.Mobs[npc.Name]

	local itemData = ItemDataBase:GetItemData(mobData.Tool)
	if itemData then
		local tool = ServerStorage:FindFirstChild("Tools"):FindFirstChild(itemData.Type):FindFirstChild(itemData.Name)
		if tool then
			local clone = tool:Clone()
			clone.Parent = npc
			ToolLoader(clone)
		end
	end
	AIService:CreateAI(npc)

	-- ---NPC Info GUI---
	-- local npcInfo = npc.NPCInfo
	-- npcInfo.Enabled = true
	-- npcInfo.Adornee = npc.Head

	-- --local HPChangerUI = require(uiModules.HPChangerUI)
	-- --HPChangerUI(hpBG, npc)

	-- npcInfo.NPCLevel.LevelText.Text = NPCService.SpawnedNPCS.Enemy[npc].Level
	-- npcInfo.NPCName.Text = npc.Name

	---When NPC Die---
	local deathAnimation = Animations:GetAnimation(npcHumanoid, "Core.Death.Animation")
	local alreadyDead = false
	npc:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(function()
		if alreadyDead == true then
			return
		end
		if VitalsService:GetVital(npc, "Health").CurrentHealth <= 0 then
			npcHumanoid.BreakJointsOnDeath = false
			alreadyDead = true
			--npcInfo.Enabled = false
			deathAnimation:Play()
			for _, KillerHit in npcHumanoid:GetChildren() do
				if KillerHit.Name == "KillerHit" and KillerHit:IsA("ObjectValue") then
					local KillerPlayer = KillerHit.Value
					GameEvents.MobKilled:Fire(KillerPlayer, npc)
				end
			end

			local attachment = npc.HumanoidRootPart:FindFirstChild("Ragdoll Attachment")
			if not attachment then
				attachment = Instance.new("Attachment")
				attachment.Parent = npc.HumanoidRootPart
				attachment.Name = "Ragdoll Attachment"
			end
			local ragdoll = Instance.new("LinearVelocity")
			ragdoll.Parent = npc.HumanoidRootPart
			ragdoll.Attachment0 = attachment
			ragdoll.MaxForce = math.huge
			ragdoll.RelativeTo = Enum.ActuatorRelativeTo.World
			ragdoll.VectorVelocity = npc.HumanoidRootPart.CFrame.LookVector * 5

			Debris:AddItem(ragdoll, 0.1)
			Debris:AddItem(npc, 15)
		end
	end)
end
