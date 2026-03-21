local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local NetworkingService = ModuleLoader:Load("Shared", "NetworkingService")
--StatusAilment HitType

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local modules = (ReplicatedStorage.Modules)
local FormulaApplier = ModuleLoader:Load("Shared", "FormulaApplier")
local StateChecker = ModuleLoader:Load("Shared", "StateChecker")
local ItemDataBase = ModuleLoader:Load("Shared", "ItemDataBase")
local KnockbackPull = ModuleLoader:Load("Server", "KnockbackPull")
local StateService = ModuleLoader:Load("Server", "StateService")
local Animations = ModuleLoader:Load("Shared", "Animations")
local StatusAilmentsData = ModuleLoader:Load("Shared", "StatusAilmentsData")

local AilmentService = ModuleLoader:Load("Server", "AilmentService")
local CharacterVitalsService = ModuleLoader:Load("Server", "CharacterVitalsService")


return function(argumentData)
		
	local targetHit = argumentData.TargetHit
	local attacker = argumentData.Attacker
	local player = argumentData.Player
	local abilityData = argumentData.AbilityData
	local weaponUsed = argumentData.WeaponUsed
	local targetDefenseStat = argumentData.TargetDefenseStat
	local playerDamageStat = argumentData.PlayerDamageStat
	local npcDamage = argumentData.NPCDamage
	local comboStringNumber = argumentData.ComboStringNumber
	local lastHit = argumentData.LastHit
	local statusAilments = argumentData.StatusAilments
		
	local targetHumanoid:Humanoid = targetHit:WaitForChild("Humanoid")
	local animator = targetHumanoid:FindFirstChild("Animator")
	
	local targetHRP = targetHit:WaitForChild("HumanoidRootPart")
	if not  targetHumanoid then return end
	if StateChecker:CheckState(targetHit, "Invulnerable") then return end
	local M1Damage
	local AbilityDamage
	local ailmentName
	local ailmentData
	
	StateService:AddState(attacker, "In Combat", 20)
	StateService:AddState(targetHit, "In Combat", 20)
	
	local killerHit = targetHumanoid:FindFirstChild("KillerHit")
	if killerHit and killerHit.Value == player then
		killerHit:Destroy()
	end
	killerHit = Instance.new("ObjectValue")
	killerHit.Parent = targetHumanoid
	killerHit.Value = player
	killerHit.Name = "KillerHit"	
	Debris:AddItem(killerHit, 30)
	
	NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "DefaultHit" , {
		["Target"] = targetHit ,
		["WeaponUsed"] = weaponUsed.Name,
	})
	
	
	if abilityData then		
		AbilityDamage = FormulaApplier:AbilityDamage({
			["AbilityData"] = abilityData,
			["TargetDefenseStat"] = targetDefenseStat,
			["PlayerDamageStat"] = playerDamageStat,
			["NPCDamage"] = npcDamage,	
		})
		
		print(AbilityDamage, -AbilityDamage)
		
		CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
			["HealthChange"] = -AbilityDamage

		})
		
		Animations:GetAnimation(
			animator, "Shared.Character.AbilityHitReactions."..abilityData.HitReaction
		):Play()
		StateService:AddState(targetHit, "Stunned", 0.2)
	else				
		local foundWeaponData = ItemDataBase:GetItemData(weaponUsed:GetAttribute("ID")) 
		if foundWeaponData then
			M1Damage = FormulaApplier:M1Damage({
				["NPCDamage"] = npcDamage,
				["PlayerDamageStat"] = playerDamageStat,
				["TargetDefenseStat"] = targetDefenseStat,
				["FoundWeaponData"] = foundWeaponData
				
			})
			
			CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
				["HealthChange"] = -M1Damage

			})
			

			NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound" , {
				["SoundName"] = "Weapons."..weaponUsed.Name..".Sounds.Hit."..tostring(comboStringNumber) ,
				["Parent"] = targetHRP
			})

			local hitReactionAnim = Animations:GetAnimation(
				animator, "Shared.Character.HitReactions."..tostring(comboStringNumber)
			)
			hitReactionAnim:Play()
			StateService:AddState(targetHit , "Stunned" , hitReactionAnim.Length + 0.1)
		end	
		
		------Control KnockBack------
		if lastHit then

			------EndLag Setup------
			StateService:AddState(attacker , "NoMove", .5)
			StateService:AddState(attacker , "NoPunch", 1)
			
			KnockbackPull:ApplyKnockback(targetHit,attacker,90)
		else
			KnockbackPull:ApplyKnockback(targetHit, attacker, 11)
			KnockbackPull:ApplyPull(targetHit,attacker,11)
			

		end
	end	
	
	if statusAilments then
		local randomAilment = math.random(1, #statusAilments)
		ailmentName = statusAilments[randomAilment]
		ailmentData = StatusAilmentsData.Ailments[ailmentName]
		if not ailmentData then return end
		
		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "AilmentHit",{
			["Target"] = targetHit,
			["Ailment"] = ailmentName,
			["Duration"] = ailmentData.BaseDuration,
			["State"] = ailmentData.State

		})

		NetworkingService:FireInRange("ClientEffects", targetHRP.Position, nil, "Sound",{
			["Parent"] = targetHRP,
			["SoundName"] = "Shared.Sounds.AilmentSounds."..ailmentName

		})
		
		AilmentService[ailmentName](AilmentService,attacker,targetHit, ailmentName, M1Damage or AbilityDamage)
	end

	
	if player then
		
		NetworkingService:FireToClient(player , "Hitstop", 0.03)
		
		if AbilityDamage then
			NetworkingService:FireToClient(player , "ShowDamage", AbilityDamage, false,false, false, ailmentName, ailmentData)
		else
			NetworkingService:FireToClient(player , "ShowDamage", M1Damage, false,false, false, ailmentName, ailmentData)
		end
	end

end
