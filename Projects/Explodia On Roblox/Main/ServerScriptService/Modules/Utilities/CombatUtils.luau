local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TechniqueData = require(ReplicatedStorage.Modules.Data.TechniqueData)
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local MobData = require(ReplicatedStorage.Modules.Data.MobData)
local VitalsService = require(ServerScriptService.Services.Combat.VitalsService)
local StateChecker = require(ReplicatedStorage.Modules.Helpers.StateChecker)
local DataService = require(ServerScriptService.Services.Core.DataService)
local NPCService = require(ServerScriptService.Services.NPC.NPCService)
local StatService = require(ServerScriptService.Services.Profile.StatService)
local CombatUtils = {}

CombatUtils.HitTypes = nil

function CombatUtils:ApplyKnockback(target, attacker, force)
	local targetHRP = target:WaitForChild("HumanoidRootPart")
	local knockbackAttachment = targetHRP:FindFirstChild("VelocityAttachment")
	if not knockbackAttachment then
		knockbackAttachment = Instance.new("Attachment")
		knockbackAttachment.Name = "KnockbackVelocityAttachment"
		knockbackAttachment.Parent = targetHRP
	end

	local knockbackVelocity = targetHRP:FindFirstChild("KnockBackLinVelocity")
	if not knockbackVelocity then
		knockbackVelocity = Instance.new("LinearVelocity")
		knockbackVelocity.Attachment0 = knockbackAttachment
		knockbackVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
		knockbackVelocity.MaxForce = math.huge
		knockbackVelocity.VectorVelocity = attacker.HumanoidRootPart.CFrame.LookVector * force
		knockbackVelocity.Parent = targetHRP
		knockbackAttachment.Name = "KnockBackLinVelocity"
	end

	Debris:AddItem(knockbackAttachment, 0.13)
	Debris:AddItem(knockbackVelocity, 0.13)
end

function CombatUtils:ApplyPull(target, attacker, force)
	local targetHRP = target:WaitForChild("HumanoidRootPart")
	local attackerHRP = attacker:WaitForChild("HumanoidRootPart")

	local pullAttachment = targetHRP:FindFirstChild("VelocityAttachment")
	if not pullAttachment then
		pullAttachment = Instance.new("Attachment")
		pullAttachment.Name = "PullVelocityAttachment"
		pullAttachment.Parent = attackerHRP
	end

	local pullVelocity = targetHRP:FindFirstChild("PullLinVelocity")
	if not pullVelocity then
		pullVelocity = Instance.new("LinearVelocity")
		pullVelocity.Attachment0 = pullAttachment
		pullVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
		pullVelocity.MaxForce = math.huge
		pullVelocity.VectorVelocity = attackerHRP.CFrame.LookVector * force
		pullVelocity.Parent = attackerHRP
		pullVelocity.Name = "PullLinVelocity"
	end

	Debris:AddItem(pullAttachment, 0.13)
	Debris:AddItem(pullVelocity, 0.13)
end

function CombatUtils:AddKillerHit(attacker, targetHit)
	local playerAttacker = Players:GetPlayerFromCharacter(attacker)
	if playerAttacker then
		local killerHit = targetHit:WaitForChild("Humanoid"):FindFirstChild("KillerHit")
		if killerHit and killerHit.Value == playerAttacker then
			killerHit:Destroy()
		end
		killerHit = Instance.new("ObjectValue")
		killerHit.Parent = targetHit:WaitForChild("Humanoid")
		killerHit.Value = playerAttacker
		killerHit.Name = "KillerHit"
		Debris:AddItem(killerHit, 300)
	end
end

return CombatUtils
